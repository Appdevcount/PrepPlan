# Docker for .NET Developers - Complete Guide

## Table of Contents
- [Introduction](#introduction)
- [Docker Fundamentals](#docker-fundamentals)
- [Docker for .NET - Getting Started](#docker-for-net---getting-started)
- [Dockerfile Best Practices](#dockerfile-best-practices)
- [Multi-Stage Builds](#multi-stage-builds)
- [Docker Compose](#docker-compose)
- [Container Orchestration](#container-orchestration)
- [Development Workflows](#development-workflows)
- [CI/CD Integration](#cicd-integration)
- [Azure Deployment - ACR to App Services & Container Apps](#azure-deployment---acr-to-app-services--container-apps)
- [Azure Functions with Docker](#azure-functions-with-docker)
- [Security Best Practices](#security-best-practices)
- [Performance Optimization](#performance-optimization)
- [Networking in Docker](#networking-in-docker)
- [Data Management & Volumes](#data-management--volumes)
- [Debugging & Troubleshooting](#debugging--troubleshooting)
- [Production Deployment Strategies](#production-deployment-strategies)
- [Real-World Scenarios](#real-world-scenarios)
- [Common Pitfalls & Solutions](#common-pitfalls--solutions)

---

## Introduction

### What is Docker?
Docker is a platform for developing, shipping, and running applications in containers. Containers package an application with all its dependencies, ensuring consistency across different environments.

### Why Docker for .NET?
- **Consistency**: Same environment in dev, test, and production
- **Isolation**: Applications run independently without conflicts
- **Portability**: Run anywhere Docker is supported
- **Scalability**: Easy horizontal scaling
- **Efficiency**: Lightweight compared to VMs
- **DevOps Integration**: Seamless CI/CD pipeline integration

### Prerequisites
- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- .NET SDK (6.0+, 7.0, 8.0)
- Basic command-line knowledge
- Understanding of .NET project structure

---

## Docker Fundamentals

### Core Concepts

#### 1. **Images**
- Read-only templates containing application code, runtime, libraries, and dependencies
- Built from Dockerfile instructions
- Stored in registries (Docker Hub, Azure Container Registry, AWS ECR)

```bash
# List images
docker images

# Pull an image
docker pull mcr.microsoft.com/dotnet/aspnet:8.0

# Remove an image
docker rmi <image-id>

# Tag an image
docker tag myapp:latest myapp:v1.0.0
```

#### 2. **Containers**
- Running instances of images
- Isolated processes with their own filesystem, network, and process tree

```bash
# Run a container
docker run -d -p 8080:80 --name myapp myapp:latest

# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop a container
docker stop myapp

# Remove a container
docker rm myapp

# View container logs
docker logs myapp

# Execute command in running container
docker exec -it myapp /bin/bash
```

#### 3. **Volumes**
- Persistent data storage outside container filesystem
- Survives container restarts and deletions

```bash
# Create a volume
docker volume create mydata

# List volumes
docker volume ls

# Inspect volume
docker volume inspect mydata

# Remove volume
docker volume rm mydata
```

#### 4. **Networks**
- Enable container communication
- Types: bridge, host, overlay, macvlan

```bash
# Create network
docker network create mynetwork

# List networks
docker network ls

# Connect container to network
docker network connect mynetwork myapp

# Inspect network
docker network inspect mynetwork
```

---

## Docker for .NET - Getting Started

### Basic Dockerfile for .NET 8 Web API

```dockerfile
# Basic Dockerfile (Not optimized - for learning purposes only)
# This simple example shows the minimal requirements but lacks optimization

# FROM: Specifies the base image - this is the runtime-only image for ASP.NET Core 8.0
# mcr.microsoft.com = Microsoft Container Registry
# Using runtime-only image means .NET SDK is NOT included (smaller size)
FROM mcr.microsoft.com/dotnet/aspnet:8.0

# WORKDIR: Sets the working directory inside the container
# All subsequent commands will run from this directory
# If the directory doesn't exist, it will be created
WORKDIR /app

# COPY: Copies files from host machine to container
# This assumes you've already built and published the app on your host
# Syntax: COPY <source-on-host> <destination-in-container>
COPY bin/Release/net8.0/publish/ .

# ENTRYPOINT: Defines the command that runs when container starts
# JSON format (exec form) is preferred - doesn't invoke shell
# This runs: dotnet MyApi.dll
ENTRYPOINT ["dotnet", "MyApi.dll"]
```

### Build and Run Commands

```bash
# Build the .NET application
dotnet publish -c Release -o out

# Build Docker image
docker build -t myapi:latest .

# Run container
docker run -d -p 5000:80 --name myapi-container myapi:latest

# Test the API
curl http://localhost:5000/api/health
```

---

## Dockerfile Best Practices

### 1. **Multi-Stage Build Pattern** (Recommended)

```dockerfile
# =============================================================================
# MULTI-STAGE BUILD - Best practice for production .NET applications
# =============================================================================
# Benefits:
# - Smaller final image (only runtime, not SDK)
# - Better layer caching (faster rebuilds)
# - Secure (build tools not in production image)
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Build
# -----------------------------------------------------------------------------
# FROM: Use SDK image (includes compiler, build tools)
# AS build: Names this stage "build" for reference in later stages
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# WORKDIR: Set working directory for build operations
WORKDIR /src

# -----------------------------------------------------------------------------
# Copy project files FIRST (for Docker layer caching)
# -----------------------------------------------------------------------------
# Why separate from source code?
# - Project files change less frequently than source code
# - If only source changes, Docker reuses cached restore layer
# - This dramatically speeds up subsequent builds
# Syntax: COPY ["<source-relative-to-context>", "<destination-in-container>"]
COPY ["MyApi/MyApi.csproj", "MyApi/"]
COPY ["MyApi.Core/MyApi.Core.csproj", "MyApi.Core/"]
COPY ["MyApi.Infrastructure/MyApi.Infrastructure.csproj", "MyApi.Infrastructure/"]

# -----------------------------------------------------------------------------
# Restore NuGet dependencies
# -----------------------------------------------------------------------------
# RUN: Executes command during image build
# dotnet restore: Downloads all NuGet packages specified in .csproj
# This layer is cached until .csproj files change
RUN dotnet restore "MyApi/MyApi.csproj"

# -----------------------------------------------------------------------------
# Copy remaining source code
# -----------------------------------------------------------------------------
# Now copy all source files (*.cs, etc.)
# Put this AFTER restore so changing code doesn't invalidate restore cache
COPY . .

# -----------------------------------------------------------------------------
# Build the application
# -----------------------------------------------------------------------------
# WORKDIR: Change to the main project directory
WORKDIR "/src/MyApi"

# RUN dotnet build:
#   -c Release: Build in Release configuration (optimized, no debug symbols)
#   -o /app/build: Output compiled files to /app/build directory
#   --no-restore: Skip restore (we already did it above)
RUN dotnet build "MyApi.csproj" -c Release -o /app/build

# -----------------------------------------------------------------------------
# Stage 2: Publish
# -----------------------------------------------------------------------------
# FROM build AS publish: Start from the "build" stage (reuse its filesystem)
# This is faster than starting from scratch
FROM build AS publish

# RUN dotnet publish:
#   -c Release: Publish release build
#   -o /app/publish: Output published files to /app/publish
#   /p:UseAppHost=false: Don't create native executable (use 'dotnet' command)
#   --no-restore: Skip restore (already done)
#   --no-build: Skip build (already done)
RUN dotnet publish "MyApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

# -----------------------------------------------------------------------------
# Stage 3: Final runtime image
# -----------------------------------------------------------------------------
# FROM: Use lightweight runtime-only image (NO SDK, much smaller ~200MB vs ~700MB)
# AS final: Name this stage "final" (optional, for multi-stage debugging)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final

# WORKDIR: Set working directory for the application
WORKDIR /app

# -----------------------------------------------------------------------------
# Create non-root user for security best practice
# -----------------------------------------------------------------------------
# RUN: Execute shell commands (using && to chain commands in single layer)
# addgroup: Create system group for the app
#   --system: System group (not a regular user group)
#   --gid 1000: Group ID 1000
# adduser: Create system user
#   --system: System user (not a regular user)
#   --uid 1000: User ID 1000
#   --ingroup appuser: Add user to appuser group
#   --shell /bin/sh: Set default shell
RUN addgroup --system --gid 1000 appuser \
    && adduser --system --uid 1000 --ingroup appuser --shell /bin/sh appuser

# -----------------------------------------------------------------------------
# Copy published application from publish stage
# -----------------------------------------------------------------------------
# COPY --from=publish: Copy files from the "publish" stage
# This brings ONLY the published output, not source code or build artifacts
# Result: Much smaller final image
COPY --from=publish /app/publish .

# -----------------------------------------------------------------------------
# Change file ownership to non-root user
# -----------------------------------------------------------------------------
# chown: Change owner and group of files
#   -R: Recursive (all files and subdirectories)
# This ensures appuser can read/write application files
RUN chown -R appuser:appuser /app

# -----------------------------------------------------------------------------
# Switch to non-root user
# -----------------------------------------------------------------------------
# USER: All subsequent commands (and container runtime) run as this user
# Security: Running as non-root limits damage if container is compromised
USER appuser

# -----------------------------------------------------------------------------
# Expose ports (documentation only - doesn't actually open ports)
# -----------------------------------------------------------------------------
# EXPOSE: Documents which ports the application listens on
# Note: This is metadata only; use -p flag in docker run to actually publish
EXPOSE 80
EXPOSE 443

# -----------------------------------------------------------------------------
# Set environment variables
# -----------------------------------------------------------------------------
# ENV: Set environment variables available at runtime
# ASPNETCORE_URLS: Tell Kestrel which URLs to listen on
#   http://+:80 means "listen on all interfaces on port 80"
# DOTNET_RUNNING_IN_CONTAINER: Informs .NET runtime it's in a container
#   Enables container-aware optimizations
ENV ASPNETCORE_URLS=http://+:80
ENV DOTNET_RUNNING_IN_CONTAINER=true

# -----------------------------------------------------------------------------
# Health check configuration
# -----------------------------------------------------------------------------
# HEALTHCHECK: Docker periodically runs this command to check container health
#   --interval=30s: Check every 30 seconds
#   --timeout=3s: Each check has 3 second timeout
#   --start-period=5s: Wait 5 seconds before first check (app startup time)
#   --retries=3: Mark unhealthy after 3 consecutive failures
# CMD: The actual health check command
#   wget: Makes HTTP request to /health endpoint
#   exit 1: Return failure code if wget fails
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/health || exit 1

# -----------------------------------------------------------------------------
# Entry point - command that runs when container starts
# -----------------------------------------------------------------------------
# ENTRYPOINT: Main process for the container
# JSON form (exec form) is preferred:
#   - No shell processing
#   - Signals (SIGTERM) sent directly to process
#   - More efficient
# This runs: dotnet MyApi.dll
ENTRYPOINT ["dotnet", "MyApi.dll"]
```

### 2. **Optimized with Build Arguments**

```dockerfile
# =============================================================================
# PARAMETERIZED BUILD - Using build arguments for flexibility
# =============================================================================
# Build with: docker build --build-arg BUILD_CONFIGURATION=Debug -t myapi .
# =============================================================================

# -----------------------------------------------------------------------------
# Define build arguments (can be overridden at build time)
# -----------------------------------------------------------------------------
# ARG: Define variables that users can pass at build-time
# These are ONLY available during build, not at runtime
# Syntax: ARG <name>=<default_value>
ARG DOTNET_VERSION=8.0
ARG BUILD_CONFIGURATION=Release

# -----------------------------------------------------------------------------
# Build stage using parameterized .NET version
# -----------------------------------------------------------------------------
# ${DOTNET_VERSION}: Variable substitution - uses ARG value
# This allows building different .NET versions without changing Dockerfile
FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION} AS build

# ARG: Re-declare inside stage to make it available in this stage
# Build args don't automatically carry over between stages
ARG BUILD_CONFIGURATION

# Set working directory
WORKDIR /src

# Copy and restore project files
# Using JSON array format for COPY is safer with spaces in paths
COPY ["MyApi/MyApi.csproj", "MyApi/"]
RUN dotnet restore "MyApi/MyApi.csproj"

# Copy all source code
COPY . .

# Navigate to project directory
WORKDIR "/src/MyApi"

# Build with parameterized configuration
# RUN with line continuations (\) for readability
RUN dotnet build "MyApi.csproj" \
    -c ${BUILD_CONFIGURATION} \     # Use Debug or Release from build arg
    -o /app/build \                 # Output directory
    --no-restore                    # Skip restore (already done)

# -----------------------------------------------------------------------------
# Publish stage
# -----------------------------------------------------------------------------
FROM build AS publish

# Re-declare ARG to use in this stage
ARG BUILD_CONFIGURATION

# Publish the application
# Multi-line format improves readability and maintainability
RUN dotnet publish "MyApi.csproj" \
    -c ${BUILD_CONFIGURATION} \     # Configuration (Debug/Release)
    -o /app/publish \               # Output to /app/publish
    --no-restore \                  # Skip restore step
    --no-build \                    # Skip build step (use existing build)
    /p:UseAppHost=false             # MSBuild property: dont create native exe

# -----------------------------------------------------------------------------
# Final runtime stage
# -----------------------------------------------------------------------------
# Using the same DOTNET_VERSION variable for consistency
FROM mcr.microsoft.com/dotnet/aspnet:${DOTNET_VERSION} AS final

WORKDIR /app

# Copy only the published output
COPY --from=publish /app/publish .

# Start the application
ENTRYPOINT ["dotnet", "MyApi.dll"]
```

### 3. **With Alpine Linux for Smaller Images**

```dockerfile
# =============================================================================
# ALPINE LINUX BUILD - Minimal image size
# =============================================================================
# Alpine Linux is a lightweight distribution (~5MB base)
# Final image: ~110MB vs ~210MB for standard Debian-based image
# Trade-off: Some compatibility issues with native libraries
# =============================================================================

# -----------------------------------------------------------------------------
# Build stage using Alpine-based SDK
# -----------------------------------------------------------------------------
# -alpine: Alpine Linux variant (musl libc instead of glibc)
# Smaller but may have compatibility issues with some NuGet packages
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build

WORKDIR /src

# Copy project file and restore
COPY ["MyApi/MyApi.csproj", "MyApi/"]
RUN dotnet restore "MyApi/MyApi.csproj"

# Copy source and publish
COPY . .
WORKDIR "/src/MyApi"
RUN dotnet publish -c Release -o /app/publish

# -----------------------------------------------------------------------------
# Final stage using Alpine runtime
# -----------------------------------------------------------------------------
# aspnet:8.0-alpine: Runtime-only Alpine image (~110MB total)
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS final

WORKDIR /app

# -----------------------------------------------------------------------------
# Install ICU libraries for internationalization support
# -----------------------------------------------------------------------------
# RUN apk: Alpine's package manager (apk = Alpine Package Keeper)
#   add: Install packages
#   --no-cache: Don't cache package index (saves space)
# icu-libs: International Components for Unicode
#   Required for culture-aware operations (dates, currencies, sorting)
RUN apk add --no-cache icu-libs

# -----------------------------------------------------------------------------
# Configure globalization settings
# -----------------------------------------------------------------------------
# ENV: Set environment variable
# DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false:
#   Tells .NET to use ICU for globalization (not invariant mode)
#   Without this, culture-specific operations will fail
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# Copy published application
COPY --from=publish /app/publish .

# Start application
ENTRYPOINT ["dotnet", "MyApi.dll"]
```

### 4. **Best Practices Summary**

```dockerfile
# =============================================================================
# PRODUCTION-READY DOCKERFILE TEMPLATE FOR .NET 8 APPLICATIONS
# =============================================================================
# This is a comprehensive, barile-tested Dockerfile incorporating:
#   ✅ Multi-stage builds (smaller images)
#   ✅ Layer caching optimization (faster builds)
#   ✅ Security best practices (non-root user, minimal attack surface)
#   ✅ Health checks (container monitoring)
#   ✅ Metadata labels (documentation)
#   ✅ Build arguments (flexibility)
#   ✅ Proper environment configuration
# =============================================================================

# -----------------------------------------------------------------------------
# Build arguments for flexibility
# -----------------------------------------------------------------------------
# ARG: Variables passed at build time (not available at runtime)
# Can be overridden: docker build --build-arg BUILD_CONFIGURATION=Debug
ARG BUILD_CONFIGURATION=Release
ARG ASPNETCORE_ENVIRONMENT=Production

# -----------------------------------------------------------------------------
# Build stage - Use specific version tag (never 'latest' in production)
# -----------------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

# -----------------------------------------------------------------------------
# Copy build configuration files FIRST
# -----------------------------------------------------------------------------
# Directory.Build.props: MSBuild properties shared across projects
#   - Common package versions
#   - Code analysis rules
#   - Build optimizations
# Copied first for better caching
COPY Directory.Build.props .

# Solution file
COPY *.sln .

# -----------------------------------------------------------------------------
# Copy ALL project files (layer caching strategy)
# -----------------------------------------------------------------------------
# Rationale: Project files change infrequently, source code changes frequently
# By separating these, we cache restore layer effectively
# Result: 10x faster rebuilds when only source changes
COPY ["src/MyApi/MyApi.csproj", "src/MyApi/"]
COPY ["src/MyApi.Core/MyApi.Core.csproj", "src/MyApi.Core/"]
COPY ["src/MyApi.Infrastructure/MyApi.Infrastructure.csproj", "src/MyApi.Infrastructure/"]

# -----------------------------------------------------------------------------
# Restore NuGet packages (cached until any .csproj changes)
# -----------------------------------------------------------------------------
# This is often the slowest step, so caching is critical
RUN dotnet restore

# -----------------------------------------------------------------------------
# Copy source code (changes frequently)
# -----------------------------------------------------------------------------
# This layer rebuilds on every code change
# But restore layer (above) remains cached
COPY src/ ./src/

# -----------------------------------------------------------------------------
# Build with strict settings
# -----------------------------------------------------------------------------
WORKDIR "/src/src/MyApi"

# dotnet build:
#   -c ${BUILD_CONFIGURATION}: Release or Debug
#   -o /app/build: Output directory
#   --no-restore: Skip restore (already done)
#   /p:TreatWarningsAsErrors=true: Fail build on warnings (enforces quality)
RUN dotnet build \
    -c ${BUILD_CONFIGURATION} \
    -o /app/build \
    --no-restore \
    /p:TreatWarningsAsErrors=true

# -----------------------------------------------------------------------------
# Publish stage - optimized output
# -----------------------------------------------------------------------------
FROM build AS publish

# Create optimized, deployment-ready output
# /p:UseAppHost=false: Don't create native executable (use 'dotnet' command)
# /p:DebugType=None: Don't generate debug info (production doesn't need PDB files)
# /p:DebugSymbols=false: Disable debug symbols (reduces size)
RUN dotnet publish \
    -c ${BUILD_CONFIGURATION} \
    -o /app/publish \
    --no-restore \
    --no-build \
    /p:UseAppHost=false \
    /p:DebugType=None \
    /p:DebugSymbols=false

# -----------------------------------------------------------------------------
# Final runtime image (smallest possible)
# -----------------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final

# -----------------------------------------------------------------------------
# Install runtime dependencies (single layer for efficiency)
# -----------------------------------------------------------------------------
# apt-get update: Refresh package repository
# --no-install-recommends: Don't install suggested packages (saves space)
# curl: For health checks
# rm -rf /var/lib/apt/lists/*: Clean up (reduces image size by 20-30MB)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# -----------------------------------------------------------------------------
# Create non-root user (critical security practice)
# -----------------------------------------------------------------------------
# Why? Root user has full system access
# If container compromised, attacker has only limited access
# Meets security compliance requirements
RUN groupadd -r appuser --gid=1000 \
    && useradd -r -g appuser --uid=1000 --create-home appuser

# -----------------------------------------------------------------------------
# Copy published application with proper ownership
# -----------------------------------------------------------------------------
# --chown=appuser:appuser: Set correct ownership immediately
# More efficient than separate chown command
COPY --from=publish --chown=appuser:appuser /app/publish .

# -----------------------------------------------------------------------------
# Switch to non-root user (from this point on, everything runs as appuser)
# -----------------------------------------------------------------------------
USER appuser

# -----------------------------------------------------------------------------
# Expose ports (documentation only, doesn't actually open ports)
# -----------------------------------------------------------------------------
# Port 8080: Standard HTTP for non-root users (>1024)
# Root-level ports (<1024) require elevated privileges
EXPOSE 8080
EXPOSE 8081

# -----------------------------------------------------------------------------
# Configure runtime environment
# -----------------------------------------------------------------------------
# ENV: Set environment variables
# ASPNETCORE_URLS: Configure Kestrel binding
# DOTNET_RUNNING_IN_CONTAINER: Enables container-aware optimizations
# DOTNET_USE_POLLING_FILE_WATCHER: Use polling (works in containers)
# DOTNET_EnableDiagnostics: 0=disable (security, performance)
ENV ASPNETCORE_URLS=http://+:8080 \
    ASPNETCORE_ENVIRONMENT=${ASPNETCORE_ENVIRONMENT} \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    DOTNET_EnableDiagnostics=0

# -----------------------------------------------------------------------------
# Add metadata labels (visible with 'docker inspect')
# -----------------------------------------------------------------------------
# Used by: Documentation, container registries, automated tooling
LABEL maintainer="your-team@company.com" \
      version="1.0" \
      description="MyApi Application"

# -----------------------------------------------------------------------------
# Configure health check (Docker monitors container health)
# -----------------------------------------------------------------------------
# Orchestrators use this to:
#   - Route traffic only to healthy containers
#   - Restart unhealthy containers
#   - Track application health metrics
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# -----------------------------------------------------------------------------
# Application entry point (JSON array format is best practice)
# -----------------------------------------------------------------------------
# exec form advantages:
#   ✅ Signals (SIGTERM) go directly to process
#   ✅ No shell process overhead
#   ✅ Faster startup, more efficient
ENTRYPOINT ["dotnet", "MyApi.dll"]
```

---

## Multi-Stage Builds

### Advanced Multi-Stage Build with Testing

```dockerfile
# =============================================================================
# ADVANCED MULTI-STAGE BUILD WITH INTEGRATED TESTING
# =============================================================================
# This Dockerfile demonstrates:
#   - Separate stages for restore, build, test, and publish
#   - Running tests as part of the build process
#   - Using --target flag to build specific stages
#   - Ensuring code quality before deployment
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Restore dependencies
# -----------------------------------------------------------------------------
# FROM ... AS restore: Name this stage "restore"
# Separating restore allows better caching granularity
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS restore

WORKDIR /src

# Copy solution and project files
# This stage caches until project structure changes
COPY ["MyApi.sln", "./"]
COPY ["src/MyApi/MyApi.csproj", "src/MyApi/"]
COPY ["src/MyApi.Core/MyApi.Core.csproj", "src/MyApi.Core/"]
COPY ["tests/MyApi.Tests/MyApi.Tests.csproj", "tests/MyApi.Tests/"]

# Restore all projects (including test projects)
# RUN dotnet restore: Downloads NuGet packages for all projects
# This layer is reused until any .csproj changes
RUN dotnet restore

# -----------------------------------------------------------------------------
# Stage 2: Build
# -----------------------------------------------------------------------------
# FROM restore AS build: Start from restore stage (inherit restored packages)
FROM restore AS build

# Copy all source code
# Now that dependencies are restored, bring in the code
COPY . .

# Build in Release configuration
# RUN dotnet build:
#   -c Release: Optimized build (no debug symbols)
#   --no-restore: Don't restore again (use cached restore)
# Compiles all projects: production code AND test projects
RUN dotnet build -c Release --no-restore

# -----------------------------------------------------------------------------
# Stage 3: Run tests (critical for CI/CD)
# -----------------------------------------------------------------------------
# FROM build AS test: Start from build stage (has compiled assemblies)
# Named "test" so can target with: docker build --target test
FROM build AS test

# Run unit/integration tests
# RUN dotnet test:
#   --no-build: Use already compiled binaries
#   -c Release: Test the Release build
#   --logger \"trx\": Output in TRX format (Test Results XML)
#   LogFileName: Name for the test results file
# If tests FAIL, the Docker build FAILS
# This prevents deploying broken code
RUN dotnet test --no-build -c Release --logger \"trx;LogFileName=test_results.trx\"

# Note: Test results are in this stage
# To extract: docker create --name mytest myapi:test
#            docker cp mytest:/src/tests/MyApi.Tests/TestResults ./test-results
#            docker rm mytest

# -----------------------------------------------------------------------------
# Stage 4: Publish
# -----------------------------------------------------------------------------
# FROM build AS publish: Start from build stage (NOT test stage)
# Why? Test failures stop the build before reaching this stage
# But we don't need test artifacts in published output
FROM build AS publish

# Publish the main application
#   \"src/MyApi/MyApi.csproj\": Main API project (not tests)
#   --no-restore, --no-build: Use cached artifacts
RUN dotnet publish \"src/MyApi/MyApi.csproj\" \
    -c Release \
    -o /app/publish \
    --no-restore \
    --no-build

# -----------------------------------------------------------------------------
# Stage 5: Final runtime (production image)
# -----------------------------------------------------------------------------
# FROM ... AS final: Lightweight runtime image
# Only contains published application (no source, no tests, no SDK)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final

WORKDIR /app

# Copy published output from publish stage
COPY --from=publish /app/publish .

# Use non-root user for security
# $APP_UID: Environment variable (if not set, runs as default user)
USER $APP_UID

# Start the application
ENTRYPOINT [\"dotnet\", \"MyApi.dll\"]

# =============================================================================
# BUILD COMMANDS:
# =============================================================================
# Test only (CI pipeline):
#   docker build --target test -t myapi:test .
#
# Full build with tests (build fails if tests fail):
#   docker build --target final -t myapi:latest .
#   (Tests run automatically, but final image doesn't include them)
#
# Skip tests (not recommended for prod):
#   docker build --target publish -t myapi:latest .
# =============================================================================
```

### Build with Different Base Images

```dockerfile
# =============================================================================
# MULTI-TARGET DOCKERFILE - Development and Production in One File
# =============================================================================
# Single Dockerfile that can build both:
#   1. Development image (with SDK and hot reload)
#   2. Production image (runtime only, optimized)
# =============================================================================

# -----------------------------------------------------------------------------
# Development image (Stage 1) - Full SDK for development workflow
# -----------------------------------------------------------------------------
# FROM ... AS development: Name this stage "development"
# Target with: docker build --target development -t myapi:dev .
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS development

WORKDIR /app

# Copy all source files (in dev, we want everything)
COPY . .

# Restore dependencies
# In development, we restore every time since we mount volumes
RUN dotnet restore

# -----------------------------------------------------------------------------
# Entry point for development with hot reload
# -----------------------------------------------------------------------------
# ENTRYPOINT: Start with file watcher
# dotnet watch run:
#   - Monitors for file changes
#   - Automatically recompiles and restarts
#   - Essential for dev productivity
# Use with volume mount:
#   docker run -v $(pwd):/app myapi:dev
# When you edit files on host, app automatically reloads
ENTRYPOINT [\"dotnet\", \"watch\", \"run\"]

# =============================================================================
# Production image (Stage 2) - Lightweight runtime
# =============================================================================

# -----------------------------------------------------------------------------
# First build the production artifacts
# -----------------------------------------------------------------------------
# Use development stage as base, but build release version
FROM development AS build

# Build and publish in Release mode
# Output to /app/bin/Release/net8.0/publish
RUN dotnet publish -c Release -o /app/bin/Release/net8.0/publish

# -----------------------------------------------------------------------------
# Final production image - Runtime only
# -----------------------------------------------------------------------------
# FROM ... AS production: Name this stage "production"
# Target with: docker build --target production -t myapi:prod .
# or simply: docker build -t myapi:prod . (production is the default)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS production

WORKDIR /app

# Copy ONLY the published output (not source code)
# --from=build: Copy from the build stage above
# This creates a minimal image with only runtime files
COPY --from=build /app/bin/Release/net8.0/publish .

# Start the published application
# No hot reload, no source code, just the compiled app
ENTRYPOINT [\"dotnet\", \"MyApi.dll\"]

# =============================================================================
# USAGE EXAMPLES:
# =============================================================================
#
# Build development image:
#   docker build --target development -t myapi:dev .
#   docker run -p 5000:80 -v $(pwd):/app myapi:dev
#
# Build production image (default):
#   docker build -t myapi:prod .
#   docker run -p 5000:80 myapi:prod
#
# In docker-compose.yml:
#   development:
#     build:
#       target: development
#   production:
#     build:
#       target: production
# =============================================================================
```

---

## Docker Compose

### Mental Model

```
Docker Compose = "Local orchestra conductor"

Think of it as a RECIPE FILE that says:
  "Start these containers, in this order,
   connected on this private network,
   with these volumes and env vars."

┌─────────────────────────────────────────────────┐
│              docker-compose.yml                 │
│                                                 │
│  services:                                      │
│    api      ──► your .NET app container         │
│    db       ──► SQL Server / Postgres           │
│    cache    ──► Redis                           │
│    queue    ──► RabbitMQ                        │
│                                                 │
│  All services share one private network         │
│  and can call each other by SERVICE NAME        │
└─────────────────────────────────────────────────┘

── Service definition sections ──────────────────────

  gateway:                      ← service name (DNS hostname on the network)
    build:
      context: ./src/Gateway    ← where to find source files (build root)
      dockerfile: Dockerfile    ← which Dockerfile to use
    ports:
      - "5000:80"               ← HOST:CONTAINER  (expose port 80 inside as 5000 outside)
    environment:
      - ASPNETCORE_ENVIRONMENT=Development   ← env vars injected at runtime
    depends_on:
      - auth-api                ← don't start gateway until these services are up
      - product-api
      - order-api
    networks:
      - frontend                ← joins BOTH networks = acts as bridge/router
      - backend                   frontend = public-facing, backend = internal only

  Rule of thumb:
    build      → how to create the image
    ports      → what host machine can reach  (omit for internal-only services)
    environment→ runtime config (use .env file or secrets for sensitive values)
    depends_on → startup ORDER (does NOT wait for health — use healthcheck for that)
    networks   → which private LANs to join (service on 2 networks = gateway role)
    volumes    → mount host path or named volume into container path

── Network isolation pattern ────────────────────────

  [Browser / External]
        │
     5000:80
        │
   ┌────▼──────────────────────────────────┐
   │  gateway  (frontend + backend)        │  ← only service with ports exposed
   └────┬──────────────────────────────────┘
        │  backend network (no external access)
   ┌────┼────────────────┐
   ▼    ▼                ▼
 auth  product         order
  api    api             api
        │
       db / redis / rabbitmq   ← deepest tier, backend only, NO ports exposed

Key mental shortcuts:
  • services   = containers to run
  • networks   = private LAN between containers
  • volumes    = persistent disks (survive restarts)
  • depends_on = startup ordering (not health readiness)
  • ports      = only expose what external callers need
  • .env file  = inject secrets without hardcoding

When to use:
  ✅ Local dev / integration testing
  ✅ Spinning up the full stack with one command
  ❌ Production at scale (use Kubernetes instead)
```

---

### Docker Compose YAML — Structure Mind Map

> **Mental Model:** A `docker-compose.yml` file has 4 top-level sections — `services` (what to run), `networks` (how containers talk), `volumes` (what persists), `secrets` (what's sensitive). Everything else is a property of one of these four.

```
docker-compose.yml
│
├── version: '3.8'                         # Compose file format version (3.x for Swarm compat)
│                                          # Omit in modern Compose v2 CLI (auto-detected)
│
├── services:                              # ─── MAIN SECTION: what containers to run ───────────
│   │
│   └── <service-name>:                    # Becomes DNS hostname on the shared network
│       │
│       ├── ── IMAGE / BUILD ──────────────────────────────────────────────────────────────────
│       │   ├── image: nginx:alpine        # Use pre-built image (OR use build:, not both)
│       │   └── build:                     # Build image from Dockerfile
│       │       ├── context: ./src/Api     # Build root — what gets sent to Docker daemon
│       │       ├── dockerfile: Dockerfile # Path to Dockerfile (relative to context)
│       │       ├── target: runtime        # Multi-stage build: stop at this stage
│       │       ├── args:                  # Build-time ARG values (not available at runtime)
│       │       │   └── BUILD_ENV: prod
│       │       └── cache_from:            # Use these images as layer cache
│       │           └── - myacr.io/api:latest
│       │
│       ├── ── IDENTITY ───────────────────────────────────────────────────────────────────────
│       │   ├── container_name: my-api     # Override auto-generated name (no scaling if set)
│       │   ├── hostname: api-host         # Hostname inside the container
│       │   └── user: "1000:1000"          # Run as UID:GID (security: avoid root)
│       │
│       ├── ── PORTS ──────────────────────────────────────────────────────────────────────────
│       │   ├── ports:                     # Publish to HOST machine (external access)
│       │   │   ├── - "8080:80"            # HOST_PORT:CONTAINER_PORT
│       │   │   ├── - "127.0.0.1:5000:80" # Bind to specific host IP (security)
│       │   │   └── - "80"                 # Random host port → container 80
│       │   └── expose:                    # Internal only — no host binding
│       │       └── - "80"                 # Documents which port the service uses
│       │
│       ├── ── ENVIRONMENT ────────────────────────────────────────────────────────────────────
│       │   ├── environment:               # Env vars injected into container
│       │   │   ├── LIST FORM:
│       │   │   │   └── - ASPNETCORE_ENVIRONMENT=Production
│       │   │   └── MAP FORM (preferred for clarity):
│       │   │       └── ASPNETCORE_ENVIRONMENT: Production
│       │   └── env_file:                  # Load vars from file (keeps secrets out of YAML)
│       │       └── - .env                 # One KEY=VALUE per line
│       │
│       ├── ── VOLUMES / MOUNTS ───────────────────────────────────────────────────────────────
│       │   └── volumes:
│       │       ├── - ./src:/app/src        # Bind mount: host path → container path (dev hot-reload)
│       │       ├── - data:/var/lib/data    # Named volume: persists across restarts
│       │       ├── - /tmp/cache:/cache     # Absolute host path
│       │       └── - type: volume          # Long form (explicit driver/options)
│       │             source: data
│       │             target: /var/lib/data
│       │             read_only: true
│       │
│       ├── ── NETWORKING ─────────────────────────────────────────────────────────────────────
│       │   └── networks:                  # Networks this service joins
│       │       ├── - frontend             # Simple form: join by name
│       │       └── backend:               # Extended form: set alias, IP
│       │             aliases:
│       │               - internal-api
│       │             ipv4_address: 172.20.0.10
│       │
│       ├── ── STARTUP ORDER ──────────────────────────────────────────────────────────────────
│       │   └── depends_on:
│       │       ├── BASIC (start order only — does NOT wait for health):
│       │       │   └── - db
│       │       └── WITH CONDITION (waits for health check to pass):
│       │           └── db:
│       │               condition: service_healthy   # requires healthcheck on db service
│       │           └── redis:
│       │               condition: service_started   # just started, no health needed
│       │
│       ├── ── HEALTH CHECK ───────────────────────────────────────────────────────────────────
│       │   └── healthcheck:
│       │       ├── test: ["CMD", "curl", "-f", "http://localhost/health"]
│       │       ├── test: ["CMD-SHELL", "pg_isready -U postgres"]  # Shell form
│       │       ├── interval: 30s          # How often to check
│       │       ├── timeout: 10s           # Max time per check
│       │       ├── retries: 3             # Failures before "unhealthy"
│       │       ├── start_period: 15s      # Grace period at startup before retries count
│       │       └── disable: true          # Disable inherited healthcheck
│       │
│       ├── ── RESTART POLICY ─────────────────────────────────────────────────────────────────
│       │   └── restart:
│       │       ├── no                     # Never restart (default)
│       │       ├── always                 # Always restart (even on clean exit)
│       │       ├── on-failure             # Restart only on non-zero exit code
│       │       └── unless-stopped         # Always restart unless manually stopped
│       │
│       ├── ── COMMAND / ENTRYPOINT ───────────────────────────────────────────────────────────
│       │   ├── command: dotnet MyApp.dll  # Override CMD from Dockerfile
│       │   ├── command: ["dotnet", "MyApp.dll"]  # Exec form (preferred)
│       │   ├── entrypoint: /entrypoint.sh # Override ENTRYPOINT from Dockerfile
│       │   └── working_dir: /app          # Set container working directory
│       │
│       ├── ── RESOURCE LIMITS ────────────────────────────────────────────────────────────────
│       │   └── deploy:                    # Resource constraints (also used in Swarm mode)
│       │       ├── replicas: 2            # Number of containers (Swarm)
│       │       └── resources:
│       │           ├── limits:            # Hard cap — container killed if exceeded
│       │           │   ├── cpus: '0.50'   # Max 50% of one CPU core
│       │           │   └── memory: 512M   # Max 512 MB RAM
│       │           └── reservations:      # Guaranteed minimum
│       │               ├── cpus: '0.25'
│       │               └── memory: 256M
│       │
│       ├── ── LOGGING ────────────────────────────────────────────────────────────────────────
│       │   └── logging:
│       │       ├── driver: json-file      # json-file | syslog | journald | none | splunk
│       │       └── options:
│       │           ├── max-size: "10m"    # Rotate log file at 10 MB
│       │           └── max-file: "3"      # Keep 3 rotated files
│       │
│       ├── ── LABELS & PROFILES ──────────────────────────────────────────────────────────────
│       │   ├── labels:                    # Metadata (used by monitoring tools, Traefik, etc.)
│       │   │   └── - "traefik.enable=true"
│       │   └── profiles:                  # Only start when profile is active
│       │       └── - debug                # docker compose --profile debug up
│       │
│       └── ── SECRETS & CONFIGS ──────────────────────────────────────────────────────────────
│           ├── secrets:                   # Mount Docker secrets into container
│           │   └── - db_password          # Mounted at /run/secrets/db_password
│           └── configs:                   # Mount config files into container
│               └── - app_config
│
├── networks:                              # ─── NETWORKING ────────────────────────────────────
│   └── <network-name>:
│       ├── driver: bridge                 # bridge (default) | host | overlay | none | macvlan
│       ├── external: true                 # Use a pre-existing network (don't create)
│       ├── name: my-shared-net            # Explicit network name (overrides auto-prefix)
│       └── ipam:                          # Custom IP management
│           └── config:
│               └── - subnet: 172.20.0.0/16
│
├── volumes:                               # ─── STORAGE ───────────────────────────────────────
│   └── <volume-name>:
│       ├── driver: local                  # local | nfs | tmpfs | custom plugin
│       ├── external: true                 # Use pre-existing volume (don't manage lifecycle)
│       ├── name: my-data-vol              # Override auto-prefixed name
│       └── driver_opts:                   # Driver-specific config
│           ├── type: nfs
│           ├── o: "addr=10.0.0.1,rw"
│           └── device: ":/nfs/share"
│
└── secrets:                               # ─── SECRETS ───────────────────────────────────────
    └── <secret-name>:
        ├── file: ./secrets/db_pass.txt    # Load secret value from file
        └── external: true                 # Use pre-existing Docker secret
```

---

### Key Property Decision Guide

| Property | Use When | Common Mistake |
|----------|----------|----------------|
| `image:` | Using published image | Don't use with `build:` on same service |
| `build:` | Building from source | Set `context:` to folder with Dockerfile |
| `ports:` | Host needs to reach service | Omit for internal services (DB, Redis) |
| `expose:` | Document internal port only | Does NOT publish to host — just documentation |
| `environment:` | Non-sensitive config | Never put passwords here directly |
| `env_file:` | Load from `.env` file | `.env` file must NOT be committed to git |
| `volumes:` bind mount | Dev hot-reload | Path must exist on host |
| `volumes:` named | DB data persistence | Named volumes survive `docker compose down` |
| `depends_on:` basic | Start order only | Does NOT wait for app readiness |
| `depends_on:` + condition | Wait for health | Service must define `healthcheck:` |
| `healthcheck:` | Signal when ready | Required for `depends_on: condition: service_healthy` |
| `restart: unless-stopped` | Long-running services | Use `no` during debugging |
| `deploy.resources.limits` | Prevent runaway usage | Memory limit = hard kill, not graceful |
| `profiles:` | Optional services | Use `--profile <name>` to activate |
| `networks:` multiple | Gateway/bridge pattern | Service on 2 nets = can route between them |

---

### docker-compose.yml Property Inheritance & Override

```
docker-compose.yml          ← base (shared config for all environments)
      +
docker-compose.override.yml ← auto-merged in dev (dev-specific overrides)
      +
docker-compose.prod.yml     ← explicit: docker compose -f dc.yml -f dc.prod.yml up

Merge rules:
  ├── scalars (image, command)  → override replaces base value
  ├── lists (ports, volumes)    → APPENDED (both lists merged)
  └── maps (environment)        → keys merged, duplicates overridden
```

---

### Basic Docker Compose for .NET API

```yaml
version: '3.8'

services:
  api:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "5000:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Server=db;Database=MyDb;User=sa;Password=YourStrong@Passw0rd;
    depends_on:
      - db
    networks:
      - mynetwork

  db:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=YourStrong@Passw0rd
    ports:
      - "1433:1433"
    volumes:
      - sqldata:/var/opt/mssql
    networks:
      - mynetwork

volumes:
  sqldata:

networks:
  mynetwork:
    driver: bridge
```

### Complete Microservices Stack

```yaml
version: '3.8'

services:
  # API Gateway
  gateway:
    build:
      context: ./src/Gateway
      dockerfile: Dockerfile
    ports:
      - "5000:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
    depends_on:
      - auth-api
      - product-api
      - order-api
    networks:
      - frontend
      - backend

  # Authentication Service
  auth-api:
    build:
      context: ./src/AuthService
      dockerfile: Dockerfile
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__AuthDb=Server=auth-db;Database=AuthDb;User=sa;Password=YourStrong@Passw0rd;
      - Redis__Connection=redis:6379
    depends_on:
      - auth-db
      - redis
    networks:
      - backend

  # Product Service
  product-api:
    build:
      context: ./src/ProductService
      dockerfile: Dockerfile
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__ProductDb=Server=product-db;Database=ProductDb;User=sa;Password=YourStrong@Passw0rd;
      - RabbitMQ__Host=rabbitmq
    depends_on:
      - product-db
      - rabbitmq
    networks:
      - backend

  # Order Service
  order-api:
    build:
      context: ./src/OrderService
      dockerfile: Dockerfile
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__OrderDb=Server=order-db;Database=OrderDb;User=sa;Password=YourStrong@Passw0rd;
      - RabbitMQ__Host=rabbitmq
    depends_on:
      - order-db
      - rabbitmq
    networks:
      - backend

  # Databases
  auth-db:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=YourStrong@Passw0rd
    volumes:
      - auth-data:/var/opt/mssql
    networks:
      - backend

  product-db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_PASSWORD=YourStrong@Passw0rd
      - POSTGRES_DB=ProductDb
    volumes:
      - product-data:/var/lib/postgresql/data
    networks:
      - backend

  order-db:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=YourStrong@Passw0rd
    volumes:
      - order-data:/var/opt/mssql
    networks:
      - backend

  # Redis Cache
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    command: redis-server --appendonly yes
    networks:
      - backend

  # RabbitMQ Message Broker
  rabbitmq:
    image: rabbitmq:3-management-alpine
    ports:
      - "5672:5672"
      - "15672:15672"
    environment:
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=admin
    volumes:
      - rabbitmq-data:/var/lib/rabbitmq
    networks:
      - backend

  # Elasticsearch
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    volumes:
      - es-data:/usr/share/elasticsearch/data
    networks:
      - backend

  # Seq Logging
  seq:
    image: datalust/seq:latest
    ports:
      - "5341:80"
    environment:
      - ACCEPT_EULA=Y
    volumes:
      - seq-data:/data
    networks:
      - backend

  # Jaeger Tracing
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "5775:5775/udp"
      - "6831:6831/udp"
      - "6832:6832/udp"
      - "5778:5778"
      - "16686:16686"
      - "14268:14268"
      - "14250:14250"
      - "9411:9411"
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge

volumes:
  auth-data:
  product-data:
  order-data:
  redis-data:
  rabbitmq-data:
  es-data:
  seq-data:
```

### Docker Compose Commands

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f api

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Rebuild services
docker-compose build

# Rebuild without cache
docker-compose build --no-cache

# Scale a service
docker-compose up -d --scale api=3

# Execute command in running service
docker-compose exec api bash

# View running services
docker-compose ps
```

### Development-Optimized Compose File

```yaml
# docker-compose.dev.yml
version: '3.8'

services:
  api:
    build:
      context: .
      dockerfile: Dockerfile.dev
      target: development
    ports:
      - "5000:80"
      - "5001:443"
    volumes:
      - ./src:/app/src
      - ~/.nuget/packages:/root/.nuget/packages:ro
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=https://+:443;http://+:80
      - ASPNETCORE_Kestrel__Certificates__Default__Path=/https/aspnetapp.pfx
      - ASPNETCORE_Kestrel__Certificates__Default__Password=password
    command: dotnet watch run --project /app/src/MyApi/MyApi.csproj

# Run with: docker-compose -f docker-compose.dev.yml up
```

---

## Container Orchestration

### Mental Model

```
Kubernetes = "Production orchestra conductor (self-healing)"

Think of it as a DESIRED STATE ENGINE:
  You say WHAT you want → K8s figures out HOW to make it happen
  and KEEPS it that way even if containers crash.

┌──────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                │
│                                                      │
│  ┌─────────────┐   ┌─────────────┐   ┌────────────┐ │
│  │    Node 1   │   │    Node 2   │   │   Node 3   │ │
│  │  [Pod][Pod] │   │  [Pod][Pod] │   │  [Pod]     │ │
│  └─────────────┘   └─────────────┘   └────────────┘ │
│                                                      │
│  Control Plane watches: "I want 3 replicas of api"   │
│  → crashes one Pod → spins up a new one instantly    │
└──────────────────────────────────────────────────────┘

Core object cheat sheet:
  Pod         = smallest unit; one or more containers
  Deployment  = "keep N replicas running, roll updates safely"
  Service     = stable DNS name + load balancer for Pods
  Ingress     = external HTTP router → routes /api → Service
  ConfigMap   = non-secret env vars / config files
  Secret      = base64-encoded sensitive values
  HPA         = auto-scale Pods based on CPU/memory

Analogy stack:
  docker run       →  Pod
  docker-compose   →  Deployment + Service
  nginx proxy      →  Ingress
  .env file        →  ConfigMap / Secret

When to use:
  ✅ Production workloads needing HA, auto-scaling, rolling deploys
  ✅ Microservices with independent scaling needs
  ❌ Simple local dev (use Docker Compose instead)
```

### K8s YAML File Anatomy — Mental Model

```
Every K8s YAML file = IDENTITY + DESIRED STATE

┌─────────────────────────────────────────────────────────────┐
│  apiVersion: apps/v1       WHO handles this?                │
│  kind: Deployment          WHAT object am I?                │
│  metadata:                 IDENTITY (name, labels, ns)      │
│    name: myapi             → unique name in namespace       │
│    namespace: production   → logical folder/isolation       │
│    labels:                 → sticky tags for filtering      │
│      app: myapi            → ← THIS is the glue             │
│  spec:                     DESIRED STATE (what I want)      │
│    ...                                                      │
└─────────────────────────────────────────────────────────────┘

── How each object uses its sections ────────────────────────

  Deployment spec:
    replicas      → how many Pods to keep alive
    selector      → which Pods do I own?  (must match template labels)
    strategy      → how to roll out changes (RollingUpdate / Recreate)
    template      → blueprint for each Pod
      └─ spec.containers
           image         → what to run
           env/envFrom   → config from ConfigMap or Secret
           resources     → requests (scheduling) vs limits (hard cap)
           livenessProbe → restart if dead
           readinessProbe→ pull from LB if not ready

  Service spec:
    type       → ClusterIP (internal) | LoadBalancer (external)
    selector   → which Pods to route to  (matches Deployment labels)
    ports      → port (Service listens) → targetPort (Pod port)

  Ingress spec:
    rules      → host + path → which Service to forward to
    tls        → cert Secret reference for HTTPS

  ConfigMap / Secret data:
    key: value → injected as env vars or mounted as files in Pods

  HPA spec:
    scaleTargetRef → points to the Deployment by name
    minReplicas / maxReplicas → scale boundaries
    metrics        → CPU % threshold that triggers scaling

── Label = the glue between all objects ─────────────────────

  Deployment  selector.matchLabels: app=myapi  ──┐
  Pod         template.labels:      app=myapi  ──┤ must ALL match
  Service     spec.selector:        app=myapi  ──┘

  If any label is wrong → Service routes to 0 Pods → 503

── apiVersion quick reference ───────────────────────────────

  Deployment, ReplicaSet          → apps/v1
  Service, ConfigMap, Secret, Pod → v1
  Ingress                         → networking.k8s.io/v1
  HPA                             → autoscaling/v2
  CronJob                         → batch/v1
```

### YAML File Sections — What Each Block Means

Every Kubernetes YAML file shares the same 4 top-level fields:

```
apiVersion  ← which API group handles this object
kind        ← WHAT object you are describing
metadata    ← identity (name, namespace, labels)
spec        ← WHAT you want (the desired state)
```

---

#### Deployment YAML — annotated

```yaml
apiVersion: apps/v1          # API group: "apps", version "v1"
kind: Deployment             # Object type → tells K8s "manage replicated Pods"
metadata:
  name: myapi-deployment     # Unique name inside the namespace
  namespace: production      # Logical isolation (like a folder for K8s objects)
  labels:
    app: myapi               # Key-value tags — used for filtering/selecting
    version: v1

spec:                        # ── DESIRED STATE starts here ──────────────────
  replicas: 3                # "I want 3 Pods running at all times"
  strategy:
    type: RollingUpdate      # How to deploy a new version
    rollingUpdate:
      maxSurge: 1            # Allow 1 EXTRA Pod during rollout (so 4 briefly)
      maxUnavailable: 0      # Never take a Pod down before a new one is ready

  selector:                  # Which Pods does THIS Deployment own?
    matchLabels:
      app: myapi             # Owns any Pod with label app=myapi

  template:                  # Blueprint for every Pod this Deployment creates
    metadata:
      labels:
        app: myapi           # MUST match selector.matchLabels above
    spec:
      containers:
      - name: myapi
        image: myacr.io/myapi:v1   # Docker image to run
        imagePullPolicy: Always    # Always pull (use IfNotPresent for speed)
        ports:
        - containerPort: 80        # Informational — what port the app listens on

        env:                       # Env vars injected into the container
        - name: ASPNETCORE_ENVIRONMENT
          value: "Production"
        - name: ConnectionStrings__DefaultConnection
          valueFrom:
            secretKeyRef:          # Pull value from a Secret (not hardcoded!)
              name: database-secret
              key: connection-string

        resources:
          requests:                # Minimum guaranteed resources (used for scheduling)
            cpu: "100m"            # 100 millicores = 0.1 CPU
            memory: "128Mi"
          limits:                  # Hard cap — container killed if exceeded
            cpu: "500m"
            memory: "256Mi"

        livenessProbe:             # "Is the container alive?" — restart if fails
          httpGet:
            path: /health/live
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 30

        readinessProbe:            # "Is the container ready for traffic?" — remove from LB if fails
          httpGet:
            path: /health/ready
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
```

**Key distinction — liveness vs readiness:**
```
livenessProbe  → RESTART the container if it fails
                 (app is deadlocked / crashed)

readinessProbe → REMOVE from load balancer if it fails
                 (app is starting up / temporarily busy)
                 Pod stays alive, just gets no traffic
```

---

#### Service YAML — annotated

```yaml
apiVersion: v1
kind: Service                # Gives Pods a stable DNS name + load balances traffic
metadata:
  name: myapi-service        # DNS name: myapi-service.production.svc.cluster.local
  namespace: production
spec:
  type: ClusterIP            # ClusterIP   = internal only (default)
                             # NodePort    = exposes on every node's IP:port
                             # LoadBalancer= creates a cloud LB (external IP)
  selector:
    app: myapi               # Forward traffic to any Pod with this label
  ports:
  - port: 80                 # Port THIS service listens on (inside cluster)
    targetPort: 80           # Port on the Pod to forward to
    protocol: TCP
```

**Service types in one line:**
```
ClusterIP     → internal cluster traffic only        (api → db)
NodePort      → opens a port on every node           (testing)
LoadBalancer  → cloud provider creates external LB   (production ingress)
```

---

#### Ingress YAML — annotated

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress                # Layer 7 HTTP router (like nginx/APIM in front of services)
metadata:
  name: myapi-ingress
  namespace: production
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /   # Ingress-controller-specific config
spec:
  rules:
  - host: api.myapp.com      # Match on hostname
    http:
      paths:
      - path: /orders        # Match on URL path
        pathType: Prefix
        backend:
          service:
            name: order-service    # Forward to this Service
            port:
              number: 80
      - path: /products
        pathType: Prefix
        backend:
          service:
            name: product-service
            port:
              number: 80
  tls:
  - hosts:
    - api.myapp.com
    secretName: myapp-tls-secret   # TLS cert stored in a Secret
```

---

#### ConfigMap & Secret — annotated

```yaml
# ConfigMap — non-sensitive config (plain text, visible in kubectl)
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapi-config
  namespace: production
data:
  ASPNETCORE_ENVIRONMENT: "Production"
  FeatureFlags__NewCheckout: "true"
  # Can also mount as a file:
  appsettings.json: |
    { "Logging": { "LogLevel": { "Default": "Warning" } } }

---
# Secret — sensitive values (base64-encoded, access-controlled)
apiVersion: v1
kind: Secret
metadata:
  name: database-secret
  namespace: production
type: Opaque
data:
  connection-string: U2VydmVyPW15c3FsOy4uLg==   # base64("Server=mysql;...")
```

**ConfigMap vs Secret rule:**
```
ConfigMap  → anything you'd put in appsettings.json
Secret     → passwords, connection strings, API keys, certs
```

---

#### How objects connect to each other

```
Deployment ──(selector: app=myapi)──► Pods
                                        │
Service    ──(selector: app=myapi)──────┘ (routes traffic to same Pods)
                                        │
Ingress    ──(backend: myapi-service)───► Service

ConfigMap / Secret ──(envFrom / valueFrom)──► Pod containers
HPA        ──(scaleTargetRef: myapi-deployment)──► Deployment
```

The **label** `app: myapi` is the glue — it's how Service and Deployment both know which Pods to talk to. If they don't match, traffic goes nowhere.

---

### Kubernetes Basics for .NET

#### 1. **Deployment Configuration**

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapi-deployment
  namespace: production
  labels:
    app: myapi
    version: v1
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: myapi
  template:
    metadata:
      labels:
        app: myapi
        version: v1
    spec:
      containers:
      - name: myapi
        image: myregistry.azurecr.io/myapi:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 80
          name: http
        - containerPort: 443
          name: https
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: "Production"
        - name: ConnectionStrings__DefaultConnection
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: connection-string
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health/live
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        volumeMounts:
        - name: app-settings
          mountPath: /app/appsettings.Production.json
          subPath: appsettings.Production.json
      volumes:
      - name: app-settings
        configMap:
          name: myapi-config
      imagePullSecrets:
      - name: acr-secret
```

#### 2. **Service Configuration**

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapi-service
  namespace: production
spec:
  type: LoadBalancer
  selector:
    app: myapi
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  - name: https
    port: 443
    targetPort: 443
    protocol: TCP
  sessionAffinity: ClientIP
```

#### 3. **Ingress Configuration**

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapi-ingress
  namespace: production
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - api.mycompany.com
    secretName: myapi-tls
  rules:
  - host: api.mycompany.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapi-service
            port:
              number: 80
```

#### 4. **ConfigMap**

```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapi-config
  namespace: production
data:
  appsettings.Production.json: |
    {
      "Logging": {
        "LogLevel": {
          "Default": "Information",
          "Microsoft.AspNetCore": "Warning"
        }
      },
      "AllowedHosts": "*",
      "ApplicationInsights": {
        "InstrumentationKey": "${AI_INSTRUMENTATION_KEY}"
      }
    }
```

#### 5. **Secrets**

```bash
# Create secret from literal
kubectl create secret generic database-secret \
  --from-literal=connection-string='Server=prod-db;Database=MyDb;User=sa;Password=SecureP@ss' \
  --namespace=production

# Create secret from file
kubectl create secret generic app-secrets \
  --from-file=./secrets/ \
  --namespace=production
```

```yaml
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: database-secret
  namespace: production
type: Opaque
stringData:
  connection-string: "Server=prod-db;Database=MyDb;User=sa;Password=SecureP@ss"
```

#### 6. **Horizontal Pod Autoscaler**

```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapi-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapi-deployment
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 30
      - type: Pods
        value: 2
        periodSeconds: 30
      selectPolicy: Max
```

### Kubernetes Commands

```bash
# Apply configurations
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

# Get resources
kubectl get pods -n production
kubectl get deployments -n production
kubectl get services -n production

# Describe resource
kubectl describe pod <pod-name> -n production

# View logs
kubectl logs <pod-name> -n production
kubectl logs -f <pod-name> -n production  # Follow logs

# Execute commands in pod
kubectl exec -it <pod-name> -n production -- /bin/bash

# Port forward
kubectl port-forward <pod-name> 8080:80 -n production

# Scale deployment
kubectl scale deployment myapi-deployment --replicas=5 -n production

# Update image
kubectl set image deployment/myapi-deployment myapi=myregistry.azurecr.io/myapi:v2 -n production

# Rollback deployment
kubectl rollout undo deployment/myapi-deployment -n production

# View rollout status
kubectl rollout status deployment/myapi-deployment -n production

# View rollout history
kubectl rollout history deployment/myapi-deployment -n production
```

---

## Helm

### Mental Model

```
Helm = "Package manager for Kubernetes"
       (think: apt/npm/nuget, but for K8s YAML)

Problem Helm solves:
  K8s needs many YAML files (Deployment, Service, Ingress,
  ConfigMap, Secret...). Copying and tweaking them for each
  environment (dev/staging/prod) is error-prone.

Helm wraps all those YAMLs into a versioned, parameterised PACKAGE called a CHART.

┌──────────────────────────────────────────────────────────┐
│                      Helm Chart                          │
│                                                          │
│  mychart/                                                │
│    Chart.yaml        ← chart name, version, description  │
│    values.yaml       ← DEFAULT config values             │
│    templates/        ← K8s YAML with {{ .Values.xxx }}   │
│      deployment.yaml                                     │
│      service.yaml                                        │
│      ingress.yaml                                        │
│      configmap.yaml                                      │
└──────────────────────────────────────────────────────────┘

How it works:
  1. You write templates once with {{ placeholders }}
  2. values.yaml holds defaults
  3. Override per-environment:
       helm install myapi ./mychart -f values.prod.yaml

Key concepts:
  Chart    = the package (template + default values)
  Release  = a deployed instance of a chart ("myapi-prod")
  Values   = the config injected at deploy time
  Repo     = registry of charts (like npm registry)

Common commands cheat sheet:
  helm install   <release> <chart>          # first deploy
  helm upgrade   <release> <chart>          # update / redeploy
  helm rollback  <release> <revision>       # undo a bad deploy
  helm uninstall <release>                  # tear down
  helm list                                 # see all releases
  helm template  <chart> -f values.yaml     # preview rendered YAML

Analogy:
  values.yaml      →  appsettings.json  (defaults)
  -f values.prod   →  appsettings.Production.json (overrides)
  helm install     →  dotnet publish + deploy
  helm rollback    →  git revert + redeploy

When to use:
  ✅ Deploying the same app to multiple environments
  ✅ Distributing reusable infrastructure components
  ✅ Versioning K8s deployments with rollback capability
  ❌ Simple one-off deployments (plain kubectl apply is fine)
```

### Helm File Anatomy — Mental Model

```
A Helm chart = a FOLDER that produces K8s YAML on demand.

myapi-chart/
│
├── Chart.yaml          WHO am I?  (chart identity & version)
├── values.yaml         WHAT are the defaults?  (your knobs)
├── values.prod.yaml    WHAT changes in prod?   (overrides only)
│
└── templates/          HOW do I look?  (K8s YAML with {{ }} holes)
    ├── _helpers.tpl    shared named blocks (NOT rendered as K8s objects)
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml    wrapped in {{- if .Values.ingress.enabled }}
    ├── configmap.yaml
    ├── secret.yaml
    └── hpa.yaml        wrapped in {{- if .Values.autoscaling.enabled }}

── File responsibilities ────────────────────────────────────

  Chart.yaml      name / version / appVersion / description
                  version   → chart version (bump when template changes)
                  appVersion→ app version   (informational only)

  values.yaml     ALL configurable knobs with safe defaults
                  Organised by concern:
                    image:       repository + tag + pullPolicy
                    service:     type + port
                    ingress:     enabled + host + tls
                    env:         non-secret env vars (→ ConfigMap)
                    secrets:     sensitive values (always empty here!)
                    resources:   requests + limits
                    probes:      liveness + readiness paths
                    autoscaling: enabled + min/max + CPU target

  values.prod.yaml  ONLY what differs from defaults
                    Never a full copy — just the overrides

  _helpers.tpl    Named template functions, e.g.:
                    "myapi-chart.fullname"      → release + chart name
                    "myapi-chart.labels"        → standard K8s labels block
                    "myapi-chart.selectorLabels"→ subset used by selector
                  Called with: {{ include "myapi-chart.fullname" . }}

── Template syntax at a glance ─────────────────────────────

  {{ .Values.x }}           → read from values.yaml
  {{ .Release.Name }}       → name given at helm install
  {{ .Release.Namespace }}  → -n flag value
  {{ .Chart.Name }}         → Chart.yaml → name
  {{- include "tpl" . | nindent 4 }}  → call helper, indent 4sp
  | b64enc                  → base64 encode  (Secrets)
  | quote                   → wrap in quotes
  | default "x"             → fallback if empty
  {{- if .Values.x }} ... {{- end }}   → conditional block
  {{- range $k,$v := .Values.env }}    → loop over map

── How values layer together ───────────────────────────────

  values.yaml          ← base (lowest priority)
       +
  values.prod.yaml     ← environment override (-f flag)
       +
  --set image.tag=123  ← CLI override (highest priority)
       =
  Final rendered YAML sent to K8s

── The 3-command workflow ───────────────────────────────────

  1. helm template  → preview rendered YAML (no cluster needed)
  2. helm upgrade --install --dry-run → validate against cluster
  3. helm upgrade --install          → deploy for real
```

### Full Chart — File-by-File with Explanation

#### Chart folder structure

```
myapi-chart/
├── Chart.yaml                 ← chart identity & metadata
├── values.yaml                ← default values (override per environment)
├── values.staging.yaml        ← staging overrides
├── values.prod.yaml           ← production overrides
└── templates/
    ├── _helpers.tpl           ← reusable named templates (like helper functions)
    ├── deployment.yaml        ← Deployment object
    ├── service.yaml           ← Service object
    ├── ingress.yaml           ← Ingress object
    ├── configmap.yaml         ← ConfigMap object
    ├── secret.yaml            ← Secret object
    └── hpa.yaml               ← HorizontalPodAutoscaler
```

---

#### `Chart.yaml` — Chart identity

```yaml
apiVersion: v2                  # Helm 3 uses v2
name: myapi-chart               # Chart name (used in helm install/upgrade)
description: ASP.NET Core API Helm chart
type: application               # "application" = deployable app | "library" = shared helpers only
version: 1.3.0                  # Chart version — bump when you change the chart itself
appVersion: "2.1.0"             # App version — informational, reflects the app being packaged
```

---

#### `values.yaml` — Defaults (the single source of truth)

```yaml
# ── Replica & image ─────────────────────────────────
replicaCount: 2

image:
  repository: myacr.azurecr.io/myapi   # ACR / Docker Hub image path
  tag: "latest"                         # overridden per deploy via --set image.tag=build-123
  pullPolicy: IfNotPresent              # Always | IfNotPresent | Never

# ── Service ─────────────────────────────────────────
service:
  type: ClusterIP    # ClusterIP | NodePort | LoadBalancer
  port: 80
  targetPort: 80

# ── Ingress ──────────────────────────────────────────
ingress:
  enabled: true
  host: api.myapp.com
  path: /
  tls:
    enabled: false
    secretName: myapp-tls-secret

# ── Environment variables ────────────────────────────
env:
  ASPNETCORE_ENVIRONMENT: "Production"
  FeatureFlags__NewCheckout: "false"

# ── Secrets (actual values set via --set or CI pipeline) ──
secrets:
  connectionString: ""           # Never commit real values here
  jwtSecret: ""

# ── Resource limits ──────────────────────────────────
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "256Mi"

# ── Health probes ────────────────────────────────────
probes:
  liveness:
    path: /health/live
    initialDelaySeconds: 10
    periodSeconds: 30
  readiness:
    path: /health/ready
    initialDelaySeconds: 5
    periodSeconds: 10

# ── Autoscaling ──────────────────────────────────────
autoscaling:
  enabled: false
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

---

#### `values.staging.yaml` — Staging overrides only

```yaml
# Only declare what's DIFFERENT from values.yaml
replicaCount: 1

image:
  tag: "staging-latest"

ingress:
  host: api.staging.myapp.com

env:
  ASPNETCORE_ENVIRONMENT: "Staging"
  FeatureFlags__NewCheckout: "true"   # test new feature in staging

resources:
  requests:
    cpu: "50m"
    memory: "64Mi"
  limits:
    cpu: "200m"
    memory: "128Mi"
```

---

#### `values.prod.yaml` — Production overrides only

```yaml
replicaCount: 3

image:
  tag: "1.5.2"           # pinned version in prod, never "latest"
  pullPolicy: Always

ingress:
  host: api.myapp.com
  tls:
    enabled: true
    secretName: myapp-tls-secret

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 20
  targetCPUUtilizationPercentage: 60

resources:
  requests:
    cpu: "250m"
    memory: "256Mi"
  limits:
    cpu: "1000m"
    memory: "512Mi"
```

---

#### `templates/_helpers.tpl` — Reusable named templates

```yaml
{{/*
  Expand the name of the chart.
  Usage: {{ include "myapi-chart.name" . }}
*/}}
{{- define "myapi-chart.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}   {{/* K8s names max 63 chars */}}
{{- end }}

{{/*
  Full release name: "myapi-prod-myapi-chart"
  Truncated to 63 chars to satisfy K8s constraints.
*/}}
{{- define "myapi-chart.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels applied to every object — used for kubectl filtering
*/}}
{{- define "myapi-chart.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ include "myapi-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
  Selector labels — subset used by Service/Deployment selector
*/}}
{{- define "myapi-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "myapi-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
```

**Why `_helpers.tpl` matters:**
- The `_` prefix means Helm does NOT render it as a K8s object
- `include "myapi-chart.labels" .` injects the block anywhere, keeping all objects consistently labelled
- Avoids copy-pasting the same labels into every template file

---

#### `templates/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapi-chart.fullname" . }}         {{/* e.g. "myapi-prod-myapi-chart" */}}
  namespace: {{ .Release.Namespace }}                  {{/* set via helm install -n <ns> */}}
  labels:
    {{- include "myapi-chart.labels" . | nindent 4 }}  {{/* inject common labels, indent 4 spaces */}}
spec:
  {{- if not .Values.autoscaling.enabled }}            {{/* if HPA manages replicas, don't set here */}}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "myapi-chart.selectorLabels" . | nindent 6 }}
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        {{- include "myapi-chart.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.targetPort }}
              protocol: TCP

          # ── Env vars from ConfigMap ──────────────────
          envFrom:
            - configMapRef:
                name: {{ include "myapi-chart.fullname" . }}-config

          # ── Sensitive env vars from Secret ───────────
          env:
            - name: ConnectionStrings__Default
              valueFrom:
                secretKeyRef:
                  name: {{ include "myapi-chart.fullname" . }}-secret
                  key: connectionString
            - name: Jwt__Secret
              valueFrom:
                secretKeyRef:
                  name: {{ include "myapi-chart.fullname" . }}-secret
                  key: jwtSecret

          # ── Resource limits ──────────────────────────
          resources:
            requests:
              cpu: {{ .Values.resources.requests.cpu }}
              memory: {{ .Values.resources.requests.memory }}
            limits:
              cpu: {{ .Values.resources.limits.cpu }}
              memory: {{ .Values.resources.limits.memory }}

          # ── Health probes ────────────────────────────
          livenessProbe:
            httpGet:
              path: {{ .Values.probes.liveness.path }}
              port: http
            initialDelaySeconds: {{ .Values.probes.liveness.initialDelaySeconds }}
            periodSeconds: {{ .Values.probes.liveness.periodSeconds }}
          readinessProbe:
            httpGet:
              path: {{ .Values.probes.readiness.path }}
              port: http
            initialDelaySeconds: {{ .Values.probes.readiness.initialDelaySeconds }}
            periodSeconds: {{ .Values.probes.readiness.periodSeconds }}
```

---

#### `templates/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "myapi-chart.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "myapi-chart.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  selector:
    {{- include "myapi-chart.selectorLabels" . | nindent 4 }}   {{/* targets the Pods from Deployment */}}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
      protocol: TCP
      name: http
```

---

#### `templates/ingress.yaml`

```yaml
{{- if .Values.ingress.enabled }}    {{/* only render if ingress.enabled: true in values */}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "myapi-chart.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "myapi-chart.labels" . | nindent 4 }}
spec:
  {{- if .Values.ingress.tls.enabled }}
  tls:
    - hosts:
        - {{ .Values.ingress.host }}
      secretName: {{ .Values.ingress.tls.secretName }}
  {{- end }}
  rules:
    - host: {{ .Values.ingress.host }}
      http:
        paths:
          - path: {{ .Values.ingress.path }}
            pathType: Prefix
            backend:
              service:
                name: {{ include "myapi-chart.fullname" . }}
                port:
                  number: {{ .Values.service.port }}
{{- end }}
```

---

#### `templates/configmap.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "myapi-chart.fullname" . }}-config
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "myapi-chart.labels" . | nindent 4 }}
data:
  {{- range $key, $value := .Values.env }}   {{/* loop over all key-value pairs in .Values.env */}}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
```

**What `range` does:** iterates every entry in `values.yaml → env:` block and writes it as a ConfigMap key. Adding a new env var to `values.yaml` automatically appears in the ConfigMap — no template change needed.

---

#### `templates/secret.yaml`

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "myapi-chart.fullname" . }}-secret
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "myapi-chart.labels" . | nindent 4 }}
type: Opaque
data:
  # b64enc encodes the value — K8s Secrets store base64
  connectionString: {{ .Values.secrets.connectionString | b64enc | quote }}
  jwtSecret: {{ .Values.secrets.jwtSecret | b64enc | quote }}
```

**In CI/CD, never put real secrets in values files. Pass them at deploy time:**
```bash
helm upgrade --install myapi-prod ./myapi-chart \
  -f values.prod.yaml \
  --set secrets.connectionString="Server=prod-db;..." \
  --set secrets.jwtSecret="$JWT_SECRET" \
  --set image.tag="$BUILD_TAG"
```

---

#### `templates/hpa.yaml`

```yaml
{{- if .Values.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "myapi-chart.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "myapi-chart.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "myapi-chart.fullname" . }}   {{/* must match the Deployment name exactly */}}
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

---

#### Template syntax cheat sheet

```
{{ .Values.x }}             read a value from values.yaml
{{ .Release.Name }}         the release name given at helm install
{{ .Release.Namespace }}    namespace the chart is installed into
{{ .Chart.Name }}           chart name from Chart.yaml
{{ .Chart.Version }}        chart version from Chart.yaml

{{- ... -}}                 strip whitespace before/after (avoid blank lines in output)
{{ include "tpl" . }}       call a named template from _helpers.tpl
| nindent 4                 indent the output 4 spaces (needed after labels: block)
| quote                     wrap value in quotes
| b64enc                    base64-encode a string (for Secrets)
| default "fallback"        use fallback if value is empty
{{- if .Values.x }} ... {{- end }}    conditional block
{{- range $k, $v := .Values.env }}   loop over a map
```

---

#### Full deploy workflow

```bash
# 1. Preview what YAML Helm will generate (no cluster needed)
helm template myapi-prod ./myapi-chart -f values.prod.yaml

# 2. Validate against a live cluster
helm install myapi-prod ./myapi-chart -f values.prod.yaml --dry-run

# 3. First deploy
helm install myapi-prod ./myapi-chart \
  -f values.prod.yaml \
  --set image.tag="1.5.2" \
  --set secrets.connectionString="$DB_CONN" \
  -n production --create-namespace

# 4. Subsequent deploys (upgrade; install if not exists)
helm upgrade --install myapi-prod ./myapi-chart \
  -f values.prod.yaml \
  --set image.tag="$BUILD_TAG" \
  --set secrets.connectionString="$DB_CONN" \
  -n production

# 5. See all releases
helm list -n production

# 6. See history for a release
helm history myapi-prod -n production

# 7. Rollback to previous revision
helm rollback myapi-prod 2 -n production

# 8. Tear down
helm uninstall myapi-prod -n production
```

---

## Development Workflows

### 1. **Local Development with Docker**

```bash
# Build development image
docker build -t myapi:dev -f Dockerfile.dev .

# Run with volume mount for hot reload
docker run -d \
  -p 5000:80 \
  -v $(pwd)/src:/app/src \
  -e ASPNETCORE_ENVIRONMENT=Development \
  --name myapi-dev \
  myapi:dev

# Watch logs
docker logs -f myapi-dev
```

### 2. **Development Dockerfile with Hot Reload**

```dockerfile
# =============================================================================
# DEVELOPMENT DOCKERFILE - Optimized for local development
# =============================================================================
# File: Dockerfile.dev
# Usage: docker build -f Dockerfile.dev -t myapi:dev .
# Features: Hot reload, development tools, debugging support
# =============================================================================

# -----------------------------------------------------------------------------
# Use SDK image (includes development tools)
# -----------------------------------------------------------------------------
# AS development: Name stage for clarity (development vs production)
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS development

WORKDIR /app

# -----------------------------------------------------------------------------
# Install .NET development tools
# -----------------------------------------------------------------------------
# RUN dotnet tool install:
#   --global: Install tool globally (available system-wide)
# dotnet-ef: Entity Framework Core command-line tools
#   Used for: migrations, database updates, scaffolding
RUN dotnet tool install --global dotnet-ef

# dotnet-aspnet-codegenerator: ASP.NET Core scaffolding tool
#   Used for: generating controllers, views, pages
RUN dotnet tool install --global dotnet-aspnet-codegenerator

# ENV PATH: Add .NET tools to PATH so they're accessible
# ${PATH}: Preserve existing PATH variable
# /root/.dotnet/tools: Where .NET global tools are installed
ENV PATH="${PATH}:/root/.dotnet/tools"

# -----------------------------------------------------------------------------
# Copy and restore project files (for dependency caching)
# -----------------------------------------------------------------------------
# Copy solution file
COPY *.sln .

# Copy project files (csproj)
COPY src/MyApi/*.csproj ./src/MyApi/

# Restore NuGet packages
# In dev, we do this separately for better caching
RUN dotnet restore

# -----------------------------------------------------------------------------
# Copy source code
# -----------------------------------------------------------------------------
# Copy all source files
# In development, we often mount this as a volume for hot reload
COPY . .

# Switch to project directory
WORKDIR /app/src/MyApi

# -----------------------------------------------------------------------------
# Enable hot reload functionality
# -----------------------------------------------------------------------------
# ENV: Set environment variables for development features

# DOTNET_USE_POLLING_FILE_WATCHER=true:
#   Use polling instead of native file system events
#   Required for hot reload to work in Docker volumes (especially on Mac/Windows)
#   Native file events don't propagate from host to container
ENV DOTNET_USE_POLLING_FILE_WATCHER=true

# DOTNET_WATCH_RESTART_ON_RUDE_EDIT=true:
#   Restart app on "rude edits" (changes that can't be hot-reloaded)
#   Examples: adding new files, changing class signatures
ENV DOTNET_WATCH_RESTART_ON_RUDE_EDIT=true

# -----------------------------------------------------------------------------
# Start command with hot reload
# -----------------------------------------------------------------------------
# CMD: Default command (can be overridden at runtime)
# dotnet watch run:
#   Monitors for file changes and automatically restarts/reloads
# --urls http://0.0.0.0:80:
#   Listen on all interfaces (0.0.0.0) so accessible from host
#   Port 80 for standard HTTP
CMD ["dotnet", "watch", "run", "--urls", "http://0.0.0.0:80"]
```

### 3. **docker-compose.override.yml for Development**

```yaml
# docker-compose.override.yml (automatically merged with docker-compose.yml)
version: '3.8'

services:
  api:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - ./src:/app/src:delegated
      - ~/.nuget/packages:/root/.nuget/packages:ro
      - ~/.dotnet:/root/.dotnet:ro
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:80
    ports:
      - "5000:80"
      - "40000:40000"  # Debugging port

  db:
    ports:
      - "1433:1433"
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=DevPassword123!
```

### 4. **VS Code Launch Configuration**

```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Docker .NET Launch",
      "type": "docker",
      "request": "launch",
      "preLaunchTask": "docker-run: debug",
      "netCore": {
        "appProject": "${workspaceFolder}/src/MyApi/MyApi.csproj"
      }
    },
    {
      "name": "Docker Attach",
      "type": "docker",
      "request": "attach",
      "platform": "netCore",
      "sourceFileMap": {
        "/app": "${workspaceFolder}"
      }
    }
  ]
}
```

### 5. **Makefile for Common Tasks**

```makefile
# Makefile
.PHONY: help build run test clean deploy

help:
	@echo "Available targets:"
	@echo "  build    - Build Docker image"
	@echo "  run      - Run containers with docker-compose"
	@echo "  test     - Run tests"
	@echo "  clean    - Stop and remove containers"
	@echo "  deploy   - Deploy to production"

build:
	docker-compose build

run:
	docker-compose up -d
	@echo "Application running at http://localhost:5000"

test:
	docker-compose run --rm api dotnet test

clean:
	docker-compose down -v
	docker system prune -f

deploy:
	docker build -t myregistry.azurecr.io/myapi:$(VERSION) .
	docker push myregistry.azurecr.io/myapi:$(VERSION)
	kubectl set image deployment/myapi-deployment myapi=myregistry.azurecr.io/myapi:$(VERSION)

logs:
	docker-compose logs -f

shell:
	docker-compose exec api /bin/bash

db-migrate:
	docker-compose exec api dotnet ef database update
```

---

## CI/CD Integration

### 1. **GitHub Actions**

```yaml
# .github/workflows/docker-build-deploy.yml
name: Docker Build and Deploy

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: myregistry.azurecr.io
  IMAGE_NAME: myapi
  
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: '8.0.x'
    
    - name: Restore dependencies
      run: dotnet restore
    
    - name: Build
      run: dotnet build --no-restore -c Release
    
    - name: Test
      run: dotnet test --no-build -c Release --logger trx --results-directory "TestResults"
    
    - name: Upload test results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: test-results
        path: TestResults

  build-and-push:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name != 'pull_request'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Log in to Azure Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ secrets.ACR_USERNAME }}
        password: ${{ secrets.ACR_PASSWORD }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}
          type=sha,prefix={{branch}}-
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:buildcache
        cache-to: type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:buildcache,mode=max
        build-args: |
          BUILD_CONFIGURATION=Release
          BUILD_NUMBER=${{ github.run_number }}

  deploy-dev:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment: development
    
    steps:
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    - name: Set up kubectl
      uses: azure/setup-kubectl@v3
    
    - name: Set AKS context
      uses: azure/aks-set-context@v3
      with:
        resource-group: my-rg-dev
        cluster-name: my-aks-dev
    
    - name: Deploy to AKS
      run: |
        kubectl set image deployment/myapi-deployment \
          myapi=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:develop \
          -n development
        kubectl rollout status deployment/myapi-deployment -n development

  deploy-prod:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    - name: Set up kubectl
      uses: azure/setup-kubectl@v3
    
    - name: Set AKS context
      uses: azure/aks-set-context@v3
      with:
        resource-group: my-rg-prod
        cluster-name: my-aks-prod
    
    - name: Deploy to AKS
      run: |
        kubectl set image deployment/myapi-deployment \
          myapi=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:main \
          -n production
        kubectl rollout status deployment/myapi-deployment -n production
```

### 2. **Azure DevOps Pipeline**

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
    - main
    - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  dockerRegistryServiceConnection: 'ACR-Connection'
  imageRepository: 'myapi'
  containerRegistry: 'myregistry.azurecr.io'
  dockerfilePath: '$(Build.SourcesDirectory)/Dockerfile'
  tag: '$(Build.BuildId)'

stages:
- stage: Build
  displayName: Build and Test
  jobs:
  - job: Build
    displayName: Build
    steps:
    - task: UseDotNet@2
      displayName: 'Install .NET SDK'
      inputs:
        packageType: 'sdk'
        version: '8.0.x'
    
    - task: DotNetCoreCLI@2
      displayName: 'Restore packages'
      inputs:
        command: 'restore'
        projects: '**/*.csproj'
    
    - task: DotNetCoreCLI@2
      displayName: 'Build solution'
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--configuration Release --no-restore'
    
    - task: DotNetCoreCLI@2
      displayName: 'Run tests'
      inputs:
        command: 'test'
        projects: '**/*Tests.csproj'
        arguments: '--configuration Release --no-build --logger trx'
        publishTestResults: true
    
    - task: Docker@2
      displayName: 'Build Docker image'
      inputs:
        command: 'build'
        repository: '$(imageRepository)'
        dockerfile: '$(dockerfilePath)'
        tags: |
          $(tag)
          latest
    
    - task: Docker@2
      displayName: 'Push to ACR'
      inputs:
        command: 'push'
        containerRegistry: '$(dockerRegistryServiceConnection)'
        repository: '$(imageRepository)'
        tags: |
          $(tag)
          latest

- stage: DeployDev
  displayName: Deploy to Development
  dependsOn: Build
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/develop'))
  jobs:
  - deployment: DeployDev
    displayName: Deploy to Dev
    environment: 'development'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: KubernetesManifest@0
            displayName: Deploy to Kubernetes
            inputs:
              action: 'deploy'
              kubernetesServiceConnection: 'AKS-Dev'
              namespace: 'development'
              manifests: |
                $(Pipeline.Workspace)/manifests/deployment.yaml
                $(Pipeline.Workspace)/manifests/service.yaml
              containers: '$(containerRegistry)/$(imageRepository):$(tag)'

- stage: DeployProd
  displayName: Deploy to Production
  dependsOn: Build
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: DeployProd
    displayName: Deploy to Production
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: KubernetesManifest@0
            displayName: Deploy to Kubernetes
            inputs:
              action: 'deploy'
              kubernetesServiceConnection: 'AKS-Prod'
              namespace: 'production'
              manifests: |
                $(Pipeline.Workspace)/manifests/deployment.yaml
                $(Pipeline.Workspace)/manifests/service.yaml
              containers: '$(containerRegistry)/$(imageRepository):$(tag)'
```

### 3. **GitLab CI/CD**

```yaml
# .gitlab-ci.yml
stages:
  - test
  - build
  - deploy

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"
  IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG

before_script:
  - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY

test:
  stage: test
  image: mcr.microsoft.com/dotnet/sdk:8.0
  script:
    - dotnet restore
    - dotnet build -c Release
    - dotnet test -c Release --no-build --logger "junit;LogFilePath=./test-results/junit.xml"
  artifacts:
    reports:
      junit: ./test-results/junit.xml

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t $IMAGE_TAG .
    - docker push $IMAGE_TAG
  only:
    - main
    - develop

deploy_dev:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context dev-cluster
    - kubectl set image deployment/myapi myapi=$IMAGE_TAG -n development
    - kubectl rollout status deployment/myapi -n development
  only:
    - develop
  environment:
    name: development
    url: https://dev-api.mycompany.com

deploy_prod:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context prod-cluster
    - kubectl set image deployment/myapi myapi=$IMAGE_TAG -n production
    - kubectl rollout status deployment/myapi -n production
  only:
    - main
  when: manual
  environment:
    name: production
    url: https://api.mycompany.com
```

---

## Azure Deployment - ACR to App Services & Container Apps

### Overview

This section covers the complete workflow for deploying containerized .NET applications to Azure:

1. **Build & Push**: Build Docker image and push to Azure Container Registry (ACR)
2. **Deploy**: Pull from ACR and deploy to Azure App Service or Azure Container Apps
3. **Automation**: Use Azure Pipelines for CI/CD
4. **Authentication**: How services authenticate and connect

### Architecture Flow

```
┌─────────────────┐
│  Source Code    │
│  (GitHub/Azure) │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│           Azure Pipeline (Build & Deploy)               │
│  ┌────────────┐  ┌──────────────┐  ┌────────────────┐  │
│  │   Build    │─▶│ Push to ACR  │─▶│ Deploy to      │  │
│  │   Docker   │  │              │  │ App Service/   │  │
│  │   Image    │  │              │  │ Container Apps │  │
│  └────────────┘  └──────────────┘  └────────────────┘  │
└─────────────────────────────────────────────────────────┘
         │                    │                  │
         ▼                    ▼                  ▼
┌─────────────────┐  ┌──────────────┐  ┌───────────────┐
│  Docker Image   │  │ Azure        │  │ Running       │
│  myapi:latest   │  │ Container    │  │ Container     │
│                 │  │ Registry     │  │ in Azure      │
└─────────────────┘  └──────────────┘  └───────────────┘
```

---

### Prerequisites

#### 1. Azure Resources Setup

```bash
# Variables
RESOURCE_GROUP="rg-myapp-prod"
LOCATION="eastus"
ACR_NAME="myappacr"  # Must be globally unique
APP_SERVICE_PLAN="plan-myapp"
APP_SERVICE_NAME="app-myapi"
CONTAINER_APP_ENV="env-myapp"
CONTAINER_APP_NAME="ca-myapi"

# Login to Azure
az login

# Set subscription (if you have multiple)
az account set --subscription "Your-Subscription-Name"

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create Azure Container Registry
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Standard \
  --admin-enabled true

# Get ACR credentials (needed for pipelines)
az acr credential show --name $ACR_NAME

# Create App Service Plan (Linux)
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP \
  --is-linux \
  --sku B1

# Create App Service (Web App for Containers)
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --name $APP_SERVICE_NAME \
  --deployment-container-image-name $ACR_NAME.azurecr.io/myapi:latest
```

#### 2. Service Principal for Authentication (Recommended for Production)

```bash
# Create Service Principal with ACR push/pull permissions
SP_NAME="sp-myapp-acr"

# Get ACR resource ID
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)

# Create service principal and assign roles
az ad sp create-for-rbac \
  --name $SP_NAME \
  --role AcrPush \
  --scope $ACR_REGISTRY_ID

# Output will show:
# {
#   "appId": "xxxx-xxxx-xxxx-xxxx",
#   "displayName": "sp-myapp-acr",
#   "password": "xxxx-xxxx-xxxx-xxxx",
#   "tenant": "xxxx-xxxx-xxxx-xxxx"
# }

# Save these values - you'll need them for Azure Pipeline
```

---

### Method 1: Azure Pipelines - Complete CI/CD

#### azure-pipelines.yml (Complete Pipeline)

```yaml
# =============================================================================
# AZURE PIPELINE FOR .NET CONTAINER DEPLOYMENT
# =============================================================================
# This pipeline:
#   1. Builds .NET application
#   2. Runs tests
#   3. Builds Docker image
#   4. Pushes to Azure Container Registry (ACR)
#   5. Deploys to Azure App Service OR Azure Container Apps
# =============================================================================

trigger:
  branches:
    include:
    - main      # Production deployments
    - develop   # Development deployments
  paths:
    exclude:
    - README.md
    - docs/*

# Pipeline variables
variables:
  # Build Configuration
  buildConfiguration: 'Release'
  dotNetVersion: '8.x'
  
  # Azure Container Registry
  azureSubscription: 'Your-Service-Connection-Name'  # Created in Azure DevOps
  containerRegistry: 'myappacr.azurecr.io'
  imageRepository: 'myapi'
  dockerfilePath: '$(Build.SourcesDirectory)/Dockerfile'
  
  # Versioning
  tag: '$(Build.BuildNumber)'
  
  # Deployment targets
  appServiceName: 'app-myapi'
  containerAppName: 'ca-myapi'
  resourceGroup: 'rg-myapp-prod'

# Agent pool (Microsoft-hosted)
pool:
  vmImage: 'ubuntu-latest'

stages:
# =============================================================================
# STAGE 1: BUILD & TEST
# =============================================================================
- stage: Build
  displayName: 'Build and Test'
  jobs:
  - job: BuildJob
    displayName: 'Build .NET Application'
    steps:
    
    # ---------------------------------------------------------------------
    # Setup .NET SDK
    # ---------------------------------------------------------------------
    - task: UseDotNet@2
      displayName: 'Install .NET SDK'
      inputs:
        packageType: 'sdk'
        version: '$(dotNetVersion)'
        installationPath: $(Agent.ToolsDirectory)/dotnet

    # ---------------------------------------------------------------------
    # Restore NuGet packages
    # ---------------------------------------------------------------------
    - task: DotNetCoreCLI@2
      displayName: 'Restore NuGet Packages'
      inputs:
        command: 'restore'
        projects: '**/*.csproj'
        feedsToUse: 'select'
        # If using private feeds:
        # vstsFeed: 'YourFeedId'

    # ---------------------------------------------------------------------
    # Build solution
    # ---------------------------------------------------------------------
    - task: DotNetCoreCLI@2
      displayName: 'Build Solution'
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--configuration $(buildConfiguration) --no-restore'

    # ---------------------------------------------------------------------
    # Run unit tests
    # ---------------------------------------------------------------------
    - task: DotNetCoreCLI@2
      displayName: 'Run Unit Tests'
      inputs:
        command: 'test'
        projects: '**/*Tests/*.csproj'
        arguments: '--configuration $(buildConfiguration) --no-build --collect:"XPlat Code Coverage" --logger trx'
        publishTestResults: true

    # ---------------------------------------------------------------------
    # Publish code coverage
    # ---------------------------------------------------------------------
    - task: PublishCodeCoverageResults@1
      displayName: 'Publish Code Coverage'
      inputs:
        codeCoverageTool: 'Cobertura'
        summaryFileLocation: '$(Agent.TempDirectory)/**/*coverage.cobertura.xml'

# =============================================================================
# STAGE 2: BUILD & PUSH DOCKER IMAGE TO ACR
# =============================================================================
- stage: ContainerBuild
  displayName: 'Build and Push Container'
  dependsOn: Build
  condition: succeeded()
  jobs:
  - job: DockerBuild
    displayName: 'Build Docker Image'
    steps:

    # ---------------------------------------------------------------------
    # Login to Azure Container Registry
    # ---------------------------------------------------------------------
    # Method 1: Using Service Connection (Recommended)
    - task: Docker@2
      displayName: 'Login to ACR'
      inputs:
        command: 'login'
        containerRegistry: '$(azureSubscription)'

    # ---------------------------------------------------------------------
    # Build Docker image
    # ---------------------------------------------------------------------
    # This task:
    #   - Reads the Dockerfile
    #   - Builds the image with multi-stage build
    #   - Tags with build number and 'latest'
    - task: Docker@2
      displayName: 'Build Docker Image'
      inputs:
        command: 'build'
        repository: '$(imageRepository)'
        dockerfile: '$(dockerfilePath)'
        containerRegistry: '$(azureSubscription)'
        tags: |
          $(tag)
          latest
        arguments: '--build-arg BUILD_CONFIGURATION=$(buildConfiguration)'

    # ---------------------------------------------------------------------
    # Scan image for vulnerabilities (optional but recommended)
    # ---------------------------------------------------------------------
    - task: trivy@1
      displayName: 'Scan Image with Trivy'
      inputs:
        image: '$(containerRegistry)/$(imageRepository):$(tag)'
        exitCode: '0'  # Don't fail pipeline on vulnerabilities (or set to 1)
      continueOnError: true

    # ---------------------------------------------------------------------
    # Push image to Azure Container Registry
    # ---------------------------------------------------------------------
    # Pushes both tags: $(tag) and 'latest'
    - task: Docker@2
      displayName: 'Push Image to ACR'
      inputs:
        command: 'push'
        repository: '$(imageRepository)'
        containerRegistry: '$(azureSubscription)'
        tags: |
          $(tag)
          latest

    # ---------------------------------------------------------------------
    # Save image information for deployment stage
    # ---------------------------------------------------------------------
    - task: Bash@3
      displayName: 'Save Image Details'
      inputs:
        targetType: 'inline'
        script: |
          echo "Image: $(containerRegistry)/$(imageRepository):$(tag)" > $(Build.ArtifactStagingDirectory)/image-info.txt
          echo "Tag: $(tag)" >> $(Build.ArtifactStagingDirectory)/image-info.txt

    # Publish artifact for deployment stage
    - task: PublishPipelineArtifact@1
      displayName: 'Publish Image Info'
      inputs:
        targetPath: '$(Build.ArtifactStagingDirectory)'
        artifactName: 'imageinfo'

# =============================================================================
# STAGE 3: DEPLOY TO AZURE APP SERVICE
# =============================================================================
- stage: DeployAppService
  displayName: 'Deploy to App Service'
  dependsOn: ContainerBuild
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: DeployToAppService
    displayName: 'Deploy Container to App Service'
    environment: 'production-appservice'  # Configure in Azure DevOps Environments
    strategy:
      runOnce:
        deploy:
          steps:
          
          # Download image info
          - task: DownloadPipelineArtifact@2
            inputs:
              artifactName: 'imageinfo'
              targetPath: '$(Pipeline.Workspace)/imageinfo'

          # -------------------------------------------------------------
          # Configure App Service to use ACR
          # -------------------------------------------------------------
          # This task:
          #   1. Authenticates App Service to ACR (using Managed Identity)
          #   2. Configures the container image to deploy
          #   3. Sets environment variables
          - task: AzureWebAppContainer@1
            displayName: 'Deploy to App Service'
            inputs:
              azureSubscription: '$(azureSubscription)'
              appName: '$(appServiceName)'
              resourceGroupName: '$(resourceGroup)'
              
              # Container settings
              containers: '$(containerRegistry)/$(imageRepository):$(tag)'
              
              # App settings (environment variables)
              appSettings: |
                -ASPNETCORE_ENVIRONMENT "Production"
                -WEBSITES_PORT "8080"
                -DOCKER_REGISTRY_SERVER_URL "https://$(containerRegistry)"
                -DOCKER_ENABLE_CI "true"

          # -------------------------------------------------------------
          # Verify deployment
          # -------------------------------------------------------------
          - task: AzureCLI@2
            displayName: 'Verify Deployment'
            inputs:
              azureSubscription: '$(azureSubscription     )'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                # Wait for app to be running
                echo "Waiting for App Service to start..."
                sleep 30
                
                # Get App Service URL
                APP_URL=$(az webapp show \
                  --name $(appServiceName) \
                  --resource-group $(resourceGroup) \
                  --query defaultHostName \
                  --output tsv)
                
                echo "App Service URL: https://$APP_URL"
                
                # Health check
                HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://$APP_URL/health)
                
                if [ $HTTP_STATUS -eq 200 ]; then
                  echo "✅ Deployment successful! Health check passed."
                else
                  echo "❌ Health check failed with status: $HTTP_STATUS"
                  exit 1
                fi

# =============================================================================
# STAGE 4: DEPLOY TO AZURE CONTAINER APPS (Alternative to App Service)
# =============================================================================
- stage: DeployContainerApps
  displayName: 'Deploy to Container Apps'
  dependsOn: ContainerBuild
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: DeployToContainerApps
    displayName: 'Deploy to Azure Container Apps'
    environment: 'production-containerapps'
    strategy:
      runOnce:
        deploy:
          steps:

          # -------------------------------------------------------------
          # Deploy to Azure Container Apps
          # -------------------------------------------------------------
          - task: AzureCLI@2
            displayName: 'Deploy to Container Apps'
            inputs:
              azureSubscription: '$(azureSubscription)'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                # Install Container Apps extension
                az extension add --name containerapp --upgrade
                
                # Get ACR credentials
                ACR_USERNAME=$(az acr credential show \
                  --name $(echo $(containerRegistry) | cut -d'.' -f1) \
                  --query username \
                  --output tsv)
                
                ACR_PASSWORD=$(az acr credential show \
                  --name $(echo $(containerRegistry) | cut -d'.' -f1) \
                  --query passwords[0].value \
                  --output tsv)
                
                # Update Container App
                az containerapp update \
                  --name $(containerAppName) \
                  --resource-group $(resourceGroup) \
                  --image $(containerRegistry)/$(imageRepository):$(tag) \
                  --registry-server $(containerRegistry) \
                  --registry-username $ACR_USERNAME \
                  --registry-password $ACR_PASSWORD \
                  --set-env-vars \
                    ASPNETCORE_ENVIRONMENT=Production \
                    ASPNETCORE_URLS=http://+:8080
                
                echo "✅ Container App updated successfully!"
                
                # Get Container App URL
                APP_URL=$(az containerapp show \
                  --name $(containerAppName) \
                  --resource-group $(resourceGroup) \
                  --query properties.configuration.ingress.fqdn \
                  --output tsv)
                
                echo "Container App URL: https://$APP_URL"

# =============================================================================
# STAGE 5: SMOKE TESTS (Post-Deployment)
# =============================================================================
- stage: SmokeTests
  displayName: 'Run Smoke Tests'
  dependsOn: 
  - DeployAppService
  - DeployContainerApps
  condition: succeededOrFailed()
  jobs:
  - job: RunSmokeTests
    displayName: 'Execute Smoke Tests'
    steps:
    
    - task: AzureCLI@2
      displayName: 'Run API Smoke Tests'
      inputs:
        azureSubscription: '$(azureSubscription)'
        scriptType: 'bash'
        scriptLocation: 'inlineScript'
        inlineScript: |
          # Get deployment URL
          APP_URL=$(az webapp show \
            --name $(appServiceName) \
            --resource-group $(resourceGroup) \
            --query defaultHostName \
            --output tsv)
          
          echo "Testing API at: https://$APP_URL"
          
          # Test health endpoint
          echo "Testing /health endpoint..."
          curl -f https://$APP_URL/health || exit 1
          
          # Test API endpoint
          echo "Testing /api/weatherforecast endpoint..."
          curl -f https://$APP_URL/api/weatherforecast || exit 1
          
          echo "✅ All smoke tests passed!"
```

---

### Method 2: Manual Deployment Steps

#### Step 1: Build and Push to ACR Manually

```bash
# =============================================================================
# MANUAL BUILD AND PUSH TO ACR
# =============================================================================

# Variables
ACR_NAME="myappacr"
IMAGE_NAME="myapi"
IMAGE_TAG="v1.0.0"

# 1. Login to Azure
az login

# 2. Login to ACR
az acr login --name $ACR_NAME

# Or using Docker directly:
# docker login $ACR_NAME.azurecr.io

# 3. Build Docker image
docker build -t $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG .

# Also tag as latest
docker tag $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG $ACR_NAME.azurecr.io/$IMAGE_NAME:latest

# 4. Push to ACR
docker push $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG
docker push $ACR_NAME.azurecr.io/$IMAGE_NAME:latest

# 5. Verify image in ACR
az acr repository list --name $ACR_NAME --output table
az acr repository show-tags --name $ACR_NAME --repository $IMAGE_NAME --output table
```

#### Step 2: Deploy to App Service

```bash
# =============================================================================
# DEPLOY FROM ACR TO AZURE APP SERVICE
# =============================================================================

APP_SERVICE_NAME="app-myapi"
RESOURCE_GROUP="rg-myapp-prod"
ACR_NAME="myappacr"
IMAGE_NAME="myapi"
IMAGE_TAG="v1.0.0"

# 1. Configure App Service to use ACR image
az webapp config container set \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --docker-custom-image-name $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG \
  --docker-registry-server-url https://$ACR_NAME.azurecr.io

# 2. Enable Managed Identity for App Service (Recommended)
az webapp identity assign \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP

# Get the identity principal ID
PRINCIPAL_ID=$(az webapp identity show \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query principalId \
  --output tsv)

# 3. Grant App Service access to ACR
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)

az role assignment create \
  --assignee $PRINCIPAL_ID \
  --role AcrPull \
  --scope $ACR_REGISTRY_ID

# 4. Configure App Service settings
az webapp config appsettings set \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings \
    ASPNETCORE_ENVIRONMENT="Production" \
    WEBSITES_PORT="8080" \
    DOCKER_ENABLE_CI="true"

# 5. Restart App Service
az webapp restart \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP

# 6. Stream logs to verify deployment
az webapp log tail \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP

# 7. Get App Service URL
az webapp show \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query defaultHostName \
  --output tsv
```

#### Step 3: Deploy to Azure Container Apps

```bash
# =============================================================================
# DEPLOY FROM ACR TO AZURE CONTAINER APPS
# =============================================================================

CONTAINER_APP_NAME="ca-myapi"
CONTAINER_APP_ENV="env-myapp"
RESOURCE_GROUP="rg-myapp-prod"
LOCATION="eastus"
ACR_NAME="myappacr"
IMAGE_NAME="myapi"
IMAGE_TAG="v1.0.0"

# 1. Install Azure Container Apps extension
az extension add --name containerapp --upgrade

# 2. Create Container Apps environment (if not exists)
az containerapp env create \
  --name $CONTAINER_APP_ENV \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# 3. Get ACR credentials
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value --output tsv)

# 4. Create Container App
az containerapp create \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINER_APP_ENV \
  --image $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG \
  --registry-server $ACR_NAME.azurecr.io \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD \
  --target-port 8080 \
  --ingress external \
  --cpu 0.5 \
  --memory 1.0Gi \
  --min-replicas 1 \
  --max-replicas 5 \
  --env-vars \
    ASPNETCORE_ENVIRONMENT=Production \
    ASPNETCORE_URLS=http://+:8080

# 5. Update existing Container App with new image
az containerapp update \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --image $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG

# 6. Get Container App URL
az containerapp show \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --query properties.configuration.ingress.fqdn \
  --output tsv

# 7. View logs
az containerapp logs show \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --follow
```

---

### Understanding the Connection Flow

#### How ACR Authentication Works

```
┌─────────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION METHODS                        │
└─────────────────────────────────────────────────────────────────┘

1. ADMIN CREDENTIALS (Simple, less secure)
   ┌──────────────┐         ┌──────────────┐
   │ App Service  │─────────▶│     ACR      │
   │ or           │ username │ (Admin       │
   │ Container    │ password │  Enabled)    │
   │ Apps         │         │              │
   └──────────────┘         └──────────────┘

2. SERVICE PRINCIPAL (Recommended for CI/CD)
   ┌──────────────┐  Client ID   ┌──────────────┐  AcrPull  ┌──────────────┐
   │   Azure      │───&────────▶│  Service     │───Role───▶│     ACR      │
   │   Pipeline   │  Secret      │  Principal   │           │              │
   └──────────────┘              └──────────────┘           └──────────────┘

3. MANAGED IDENTITY (Best for Azure Services)
   ┌──────────────┐  System      ┌──────────────┐  AcrPull  ┌──────────────┐
   │ App Service  │───Assigned──▶│  Azure AD    │───Role───▶│     ACR      │
   │ or           │  Identity    │  Identity    │           │              │
   │ Container    │              │              │           │              │
   │ Apps         │              │              │           │              │
   └──────────────┘              └──────────────┘           └──────────────┘
```

---

### Deep Dive: Authentication & Connection Process

#### Method 1: Admin Credentials (Development Only)

**When to use:** Quick prototyping, development environments  
**NOT recommended for:** Production, CI/CD pipelines

**How it works:**

```bash
# =============================================================================
# STEP 1: ENABLE ADMIN ACCESS ON ACR
# =============================================================================
# When you create ACR with --admin-enabled true, Azure generates:
#   - Admin Username (same as ACR name)
#   - Two Admin Passwords (primary and secondary)

az acr create \
  --name myappacr \
  --resource-group rg-myapp \
  --sku Standard \
  --admin-enabled true

# =============================================================================
# STEP 2: RETRIEVE ADMIN CREDENTIALS
# =============================================================================
az acr credential show --name myappacr

# Output:
# {
#   "username": "myappacr",
#   "passwords": [
#     {
#       "name": "password",
#       "value": "abc123xyz789..."  # Primary password
#     },
#     {
#       "name": "password2",
#       "value": "def456uvw012..."  # Secondary password
#     }
#   ]
# }

# =============================================================================
# STEP 3: LOGIN TO ACR USING ADMIN CREDENTIALS
# =============================================================================
# Docker login uses these credentials
docker login myappacr.azurecr.io \
  -u myappacr \
  -p abc123xyz789...

# What happens internally:
# 1. Docker sends credentials to ACR login endpoint
# 2. ACR validates username/password against stored admin credentials
# 3. ACR returns authentication token (valid for 3 hours)
# 4. Docker stores token in ~/.docker/config.json
# 5. Subsequent docker push/pull commands use this token

# =============================================================================
# STEP 4: PUSH IMAGE TO ACR
# =============================================================================
docker tag myapi:latest myappacr.azurecr.io/myapi:v1
docker push myappacr.azurecr.io/myapi:v1

# Push process:
# 1. Docker reads auth token from config.json
# 2. For each layer:
#    a. Calculate layer SHA256 hash
#    b. Check if layer exists in ACR (send HEAD request)
#    c. If not exists, upload layer blob
# 3. Upload image manifest (JSON describing layers)
# 4. Create/update tag pointing to manifest

# =============================================================================
# STEP 5: CONFIGURE APP SERVICE TO PULL FROM ACR
# =============================================================================
az webapp config container set \
  --name app-myapi \
  --resource-group rg-myapp \
  --docker-custom-image-name myappacr.azurecr.io/myapi:v1 \
  --docker-registry-server-url https://myappacr.azurecr.io \
  --docker-registry-server-user myappacr \
  --docker-registry-server-password abc123xyz789...

# What gets stored:
# App Service stores these in encrypted app settings:
#   DOCKER_REGISTRY_SERVER_URL = https://myappacr.azurecr.io
#   DOCKER_REGISTRY_SERVER_USERNAME = myappacr
#   DOCKER_REGISTRY_SERVER_PASSWORD = abc123xyz789...

# =============================================================================
# STEP 6: APP SERVICE PULLS IMAGE (Container Startup)
# =============================================================================
# When container starts/restarts:
# 1. App Service reads DOCKER_REGISTRY_SERVER_* settings
# 2. Authenticates with ACR using username/password
# 3. ACR returns access token
# 4. App Service requests image manifest
# 5. ACR validates token and returns manifest
# 6. App Service checks which layers are already cached locally
# 7. Downloads missing layers in parallel
# 8. Assembles container filesystem from layers
# 9. Starts container with specified command (ENTRYPOINT/CMD)
```

**Admin Credentials Flow Diagram:**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      ADMIN CREDENTIALS FLOW                             │
└─────────────────────────────────────────────────────────────────────────┘

    Developer          Docker CLI          ACR                App Service
        │                  │                 │                      │
        │ 1. docker login  │                 │                      │
        ├─────────────────▶│                 │                      │
        │                  │ 2. POST /oauth2/token                 │
        │                  │    (username/password)                │
        │                  ├────────────────▶│                      │
        │                  │ 3. Return JWT   │                      │
        │                  │◀────────────────┤                      │
        │                  │ Store in        │                      │
        │                  │ ~/.docker/      │                      │
        │                  │ config.json     │                      │
        │                  │                 │                      │
        │ 4. docker push   │                 │                      │
        ├─────────────────▶│                 │                      │
        │                  │ 5. PUT /v2/{repo}/manifests/{tag}     │
        │                  │    Authorization: Bearer <token>      │
        │                  ├────────────────▶│                      │
        │                  │ 6. Upload layers│                      │
        │                  ├────────────────▶│                      │
        │                  │ 7. 201 Created  │                      │
        │                  │◀────────────────┤                      │
        │                  │                 │                      │
        │                  │                 │ 8. Container Restart │
        │                  │                 │◀─────────────────────│
        │                  │                 │ 9. GET /oauth2/token │
        │                  │                 │    (username/pass)   │
        │                  │                 │◀─────────────────────│
        │                  │                 │10. Return JWT        │
        │                  │                 ├─────────────────────▶│
        │                  │                 │11. GET Manifest       │
        │                  │                 │◀─────────────────────│
        │                  │                 │12. Return Manifest    │
        │                  │                 ├─────────────────────▶│
        │                  │                 │13. GET Layers         │
        │                  │                 │◀─────────────────────│
        │                  │                 │14. Return Layer Blobs │
        │                  │                 ├─────────────────────▶│
        │                  │                 │  15. Start Container  │
        │                  │                 │      ✓ Running        │
```

---

#### Method 2: Service Principal (CI/CD Pipelines)

**When to use:** Azure DevOps, GitHub Actions, GitLab CI  
**Recommended for:** Automated deployments, CI/CD pipelines

**Complete Setup Process:**

```bash
# =============================================================================
# UNDERSTANDING SERVICE PRINCIPALS
# =============================================================================
# Service Principal = Application identity in Azure AD
# Think of it as a "service account" for applications
# Components:
#   - Application ID (Client ID): Unique identifier
#   - Client Secret: Password for the app
#   - Tenant ID: Azure AD tenant
#   - Object ID: Azure AD object identifier

# =============================================================================
# STEP 1: CREATE SERVICE PRINCIPAL WITH ACR PERMISSIONS
# =============================================================================
RESOURCE_GROUP="rg-myapp"
ACR_NAME="myappacr"
SP_NAME="sp-myapp-acr-push"

# Get ACR resource ID (needed for scoping the role)
ACR_REGISTRY_ID=$(az acr show \
  --name $ACR_NAME \
  --query id \
  --output tsv)

echo "ACR Resource ID: $ACR_REGISTRY_ID"
# Output: /subscriptions/{sub-id}/resourceGroups/rg-myapp/providers/Microsoft.ContainerRegistry/registries/myappacr

# Create Service Principal and assign AcrPush role
# This command does THREE things:
#   1. Creates app registration in Azure AD
#   2. Creates service principal (identity) for the app
#   3. Assigns RBAC role to the service principal
SP_CREDENTIALS=$(az ad sp create-for-rbac \
  --name $SP_NAME \
  --role AcrPush \
  --scope $ACR_REGISTRY_ID \
  --sdk-auth)

echo $SP_CREDENTIALS
# Output (SAVE THIS - shown only once):
# {
#   "clientId": "12345678-1234-1234-1234-123456789abc",
#   "clientSecret": "super-secret-password-xyz",
#   "subscriptionId": "abcdef01-2345-6789-abcd-ef0123456789",
#   "tenantId": "98765432-9876-5432-9876-543210987654",
#   "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
#   "resourceManagerEndpointUrl": "https://management.azure.com/",
#   "activeDirectoryGraphResourceId": "https://graph.windows.net/",
#   "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
#   "galleryEndpointUrl": "https://gallery.azure.com/",
#   "managementEndpointUrl": "https://management.core.windows.net/"
# }

# UNDERSTANDING ROLES:
#   AcrPush:  Can push and pull images (for CI/CD)
#   AcrPull:  Can only pull images (for App Service)
#   Owner:    Full access including RBAC management
#   Contributor: Can modify but not manage access

# =============================================================================
# STEP 2: VERIFY SERVICE PRINCIPAL PERMISSIONS
# =============================================================================
# Extract client ID from JSON
CLIENT_ID=$(echo $SP_CREDENTIALS | jq -r '.clientId')

# List role assignments
az role assignment list \
  --assignee $CLIENT_ID \
  --scope $ACR_REGISTRY_ID \
  --output table

# Output:
# Principal            Role     Scope
# -------------------  -------  ---------------------------------------
# sp-myapp-acr-push    AcrPush  /subscriptions/.../registries/myappacr

# =============================================================================
# STEP 3: TEST SERVICE PRINCIPAL LOGIN (Local Testing)
# =============================================================================
CLIENT_SECRET=$(echo $SP_CREDENTIALS | jq -r '.clientSecret')
TENANT_ID=$(echo $SP_CREDENTIALS | jq -r '.tenantId')

# Login to Azure CLI using Service Principal
az login --service-principal \
  -u $CLIENT_ID \
  -p $CLIENT_SECRET \
  --tenant $TENANT_ID

# Login to ACR using Service Principal
az acr login \
  --name $ACR_NAME \
  --username $CLIENT_ID \
  --password $CLIENT_SECRET

# Or use Docker directly:
docker login $ACR_NAME.azurecr.io \
  -u $CLIENT_ID \
  -p $CLIENT_SECRET

# Test push
docker tag myapi:latest $ACR_NAME.azurecr.io/myapi:test-sp
docker push $ACR_NAME.azurecr.io/myapi:test-sp
# ✓ Successfully pushed

# =============================================================================
# STEP 4: CONFIGURE AZURE DEVOPS SERVICE CONNECTION
# =============================================================================
# Option A: Using Azure DevOps UI
# 1. Go to Project Settings → Service Connections
# 2. New Service Connection → Docker Registry
# 3. Select "Azure Container Registry"
# 4. Choose "Service Principal"
# 5. Enter:
#    - Docker Registry: https://myappacr.azurecr.io
#    - Service Principal ID: {clientId}
#    - Service Principal Key: {clientSecret}
#    - Tenant ID: {tenantId}
#    - Connection Name: ACR-MyApp

# Option B: Using Azure CLI (creates connection programmatically)
# Note: Requires Azure DevOps extension
az devops service-endpoint create \
  --service-endpoint-type dockerregistry \
  --name "ACR-MyApp" \
  --url "https://$ACR_NAME.azurecr.io" \
  --username $CLIENT_ID \
  --password $CLIENT_SECRET

# =============================================================================
# STEP 5: USE SERVICE CONNECTION IN AZURE PIPELINE
# =============================================================================
# In azure-pipelines.yml:
```

**Azure Pipeline Configuration:**

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main

variables:
  # These reference the Service Connection created above
  dockerRegistryServiceConnection: 'ACR-MyApp'
  imageRepository: 'myapi'
  containerRegistry: 'myappacr.azurecr.io'
  tag: '$(Build.BuildId)'

stages:
- stage: Build
  jobs:
  - job: BuildAndPush
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    # =============================================================================
    # WHAT HAPPENS BEHIND THE SCENES:
    # =============================================================================
    # When this task runs, Azure DevOps:
    #   1. Retrieves Service Principal credentials from Service Connection
    #   2. Calls Azure AD token endpoint:
    #        POST https://login.microsoftonline.com/{tenantId}/oauth2/v2.0/token
    #        Body:
    #          client_id={clientId}
    #          client_secret={clientSecret}
    #          scope=https://management.azure.com/.default
    #          grant_type=client_credentials
    #   3. Azure AD validates credentials
    #   4. Azure AD returns access token (JWT)
    #   5. Azure DevOps uses token to call ACR token exchange endpoint:
    #        POST https://myappacr.azurecr.io/oauth2/exchange
    #        Body:
    #          grant_type=access_token
    #          service=myappacr.azurecr.io
    #          access_token={AAD_token}
    #   6. ACR validates AAD token and checks RBAC permissions
    #   7. ACR returns registry-specific refresh token
    #   8. Docker task uses refresh token for push/pull operations
    # =============================================================================
    
    - task: Docker@2
      displayName: 'Build and Push Image'
      inputs:
        command: buildAndPush
        repository: $(imageRepository)
        dockerfile: '$(Build.SourcesDirectory)/Dockerfile'
        containerRegistry: $(dockerRegistryServiceConnection)  # Uses Service Connection
        tags: |
          $(tag)
          latest
```

**Service Principal Authentication Flow:**

```
┌──────────────────────────────────────────────────────────────────────────────┐
│              SERVICE PRINCIPAL AUTHENTICATION FLOW                           │
└──────────────────────────────────────────────────────────────────────────────┘

 Azure Pipeline      Azure AD         ACR Token         ACR Registry
      │                 │              Exchange             │
      │ 1. Get SP       │                 │                 │
      │    credentials  │                 │                 │
      │    from Service │                 │                 │
      │    Connection   │                 │                 │
      │                 │                 │                 │
      │ 2. POST /oauth2/token            │                 │
      │    client_id + client_secret     │                 │
      ├────────────────▶│                 │                 │
      │                 │                 │                 │
      │                 │ 3. Validate SP  │                 │
      │                 │    credentials  │                 │
      │                 │    against      │                 │
      │                 │    Azure AD     │                 │
      │                 │                 │                 │
      │ 4. Return AAD   │                 │                 │
      │    Access Token │                 │                 │
      │    (JWT)        │                 │                 │
      │◀────────────────┤                 │                 │
      │                 │                 │                 │
      │ 5. POST /oauth2/exchange          │                 │
      │    grant_type=access_token        │                 │
      │    + AAD token  │                 │                 │
      ├─────────────────┼────────────────▶│                 │
      │                 │                 │                 │
      │                 │                 │ 6. Validate AAD │
      │                 │                 │    token        │
      │                 │                 │    signature    │
      │                 │                 │                 │
      │                 │                 │ 7. Check RBAC   │
      │                 │                 │    (AcrPush?)   │
      │                 │                 │                 │
      │                 │ 8. Return ACR refresh token       │
      │◀────────────────┼─────────────────┤                 │
      │                 │                 │                 │
      │ 9. Build Docker image             │                 │
      │                 │                 │                 │
      │10. docker push  │                 │                 │
      │    (using refresh token)          │                 │
      ├─────────────────┼─────────────────┼────────────────▶│
      │                 │                 │                 │
      │                 │                 │11. Validate     │
      │                 │                 │    refresh token│
      │                 │                 │                 │
      │                 │                 │12. Accept layers│
      │◀────────────────┼─────────────────┼─────────────────┤
      │                 │                 │                 │
      │ ✓ Push Complete │                 │                 │
```

---

#### Method 3: Managed Identity (Production - Most Secure)

**When to use:** App Service, Container Apps, AKS, Azure Functions  
**Recommended for:** Production deployments, Azure-native services

**Why Managed Identity is Best:**
- ✅ No credentials to manage or rotate
- ✅ No secrets stored in code or config
- ✅ Automatic credential rotation by Azure
- ✅ Audit trail in Azure AD
- ✅ Least privilege access

**Complete Setup Process:**

```bash
# =============================================================================
# STEP 1: ENABLE MANAGED IDENTITY ON APP SERVICE
# =============================================================================
RESOURCE_GROUP="rg-myapp"
APP_SERVICE_NAME="app-myapi"
ACR_NAME="myappacr"

# Enable System-Assigned Managed Identity
# This creates an identity in Azure AD automatically
az webapp identity assign \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP

# Output:
# {
#   "principalId": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",  # Object ID in Azure AD
#   "tenantId": "11111111-2222-3333-4444-555555555555",
#   "type": "SystemAssigned"
# }

# Save the Principal ID (we need it for RBAC)
PRINCIPAL_ID=$(az webapp identity show \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query principalId \
  --output tsv)

echo "Managed Identity Principal ID: $PRINCIPAL_ID"

# =============================================================================
# UNDERSTANDING MANAGED IDENTITY TYPES:
# =============================================================================
# System-Assigned: 
#   - Created with the resource, deleted with the resource
#   - 1:1 relationship (one identity per resource)
#   - Use for: Single app accessing Azure resources
#
# User-Assigned:
#   - Created independently, can be assigned to multiple resources
#   - Many:Many relationship
#   - Use for: Multiple apps sharing same identity
# =============================================================================

# =============================================================================
# STEP 2: GRANT MANAGED IDENTITY ACCESS TO ACR
# =============================================================================
# Get ACR resource ID
ACR_REGISTRY_ID=$(az acr show \
  --name $ACR_NAME \
  --query id \
  --output tsv)

echo "ACR Resource ID: $ACR_REGISTRY_ID"

# Assign AcrPull role to the Managed Identity
# This creates an RBAC role assignment in Azure
az role assignment create \
  --assignee $PRINCIPAL_ID \
  --role AcrPull \
  --scope $ACR_REGISTRY_ID

# What this does:
#   - Creates entry in ACR's access control (IAM)
#   - Grants permission to pull images (but not push)
#   - Permission propagates within 1-2 minutes
#   - No credentials exchanged - just permission grant

# Verify the assignment
az role assignment list \
  --assignee $PRINCIPAL_ID \
  --scope $ACR_REGISTRY_ID \
  --output table

# Output:
# Principal            Role     Scope
# -------------------  -------  ---------------------------------------
# app-myapi            AcrPull  /subscriptions/.../registries/myappacr

# =============================================================================
# STEP 3: CONFIGURE APP SERVICE TO USE ACR WITH MANAGED IDENTITY
# =============================================================================
# Configure container settings WITHOUT credentials
# App Service will use Managed Identity automatically
az webapp config container set \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --docker-custom-image-name $ACR_NAME.azurecr.io/myapi:latest \
  --docker-registry-server-url https://$ACR_NAME.azurecr.io
  # NOTE: NO --docker-registry-server-user or --docker-registry-server-password
  #       When these are omitted, App Service tries Managed Identity first

# =============================================================================
# STEP 4: ENABLE MANAGED IDENTITY FOR ACR (App Setting)
# =============================================================================
# Explicitly tell App Service to use Managed Identity for ACR
az webapp config appsettings set \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings DOCKER_REGISTRY_SERVER_URL="https://$ACR_NAME.azurecr.io"

# =============================================================================
# STEP 5: TEST THE CONFIGURATION
# =============================================================================
# Restart App Service to pull image using Managed Identity
az webapp restart \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP

# Watch logs to see authentication in action
az webapp log tail \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP

# Look for:
#   "Pulling image from Azure Container Registry using Managed Identity"
#   "Successfully pulled image using Managed Identity"
```

**Managed Identity Authentication Flow (The Magic!):**

```
┌──────────────────────────────────────────────────────────────────────────────┐
│            MANAGED IDENTITY AUTHENTICATION FLOW (MOST SECURE)                │
└──────────────────────────────────────────────────────────────────────────────┘

 App Service       Azure Instance     Azure AD         ACR
   Container         Metadata                       Registry
      │               Service                          │
      │                  │                             │
      │ 1. Container     │                             │
      │    start/restart │                             │
      │    triggered     │                             │
      │                  │                             │
      │ 2. Request token │                             │
      │    for ACR       │                             │
      │    resource      │                             │
      ├─────────────────▶│                             │
      │                  │                             │
      │                  │ 3. GET /metadata/identity/oauth2/token
      │                  │    resource=https://management.azure.com
      │                  │    Metadata: true
      │                  ├────────────────▶│            │
      │                  │                 │            │
      │                  │    4. Validate  │            │
      │                  │       Managed   │            │
      │                  │       Identity  │            │
      │                  │       (Principal│            │
      │                  │       ID)       │            │
      │                  │                 │            │
      │                  │    5. Check if identity has  │
      │                  │       valid permissions      │
      │                  │                 │            │
      │                  │    6. Generate  │            │
      │                  │       access    │            │
      │                  │       token     │            │
      │                  │       (JWT)     │            │
      │                  │                 │            │
      │                  │    7. Return AAD access token
      │                  │◀────────────────┤            │
      │                  │                 │            │
      │ 8. Return token  │                 │            │
      │◀─────────────────┤                 │            │
      │                  │                 │            │
      │ 9. Exchange AAD token for ACR-specific token    │
      │    POST https://myappacr.azurecr.io/oauth2/exchange
      │    grant_type=access_token                      │
      │    service=myappacr.azurecr.io                  │
      │    access_token={AAD_token}                     │
      ├─────────────────┼─────────────────┼────────────▶│
      │                  │                 │            │
      │                  │                 │  10. Validate
      │                  │                 │      AAD token
      │                  │                 │                        │
      │                  │                 │  11. Check RBAC
      │                  │                 │      (AcrPull role)
      │                  │                 │                        │
      │                  │                 │  12. Generate ACR
      │                  │                 │      refresh token
      │                  │                 │                        │
      │ 13. Return ACR refresh token                    │
      │◀────────────────┼─────────────────┼─────────────┤
      │                  │                 │            │
      │14. GET /v2/{repository}/manifests/{tag}         │
      │    Authorization: Bearer {refresh_token}        │
      ├─────────────────┼─────────────────┼────────────▶│
      │                  │                 │            │
      │                  │                 │  15. Validate token
      │                  │                 │                        │
      │ 16. Return image manifest                       │
      │◀────────────────┼─────────────────┼─────────────┤
      │                  │                 │            │
      │17. Download image layers                        │
      ├────────────────────────────────────────────────▶│
      │◀────────────────────────────────────────────────┤
      │                  │                 │            │
      │ 18. Start container                             │
      │     ✓ Running                                   │
      │                  │                 │            │

KEY POINTS:
  ✓ NO credentials stored anywhere
  ✓ Token obtained from Instance Metadata Service (IMDS)
  ✓ IMDS only accessible from within Azure VM/Service
  ✓ Token automatically rotates
  ✓ RBAC enforced at ACR level
```

**Understanding the Token Exchange:**

```bash
# =============================================================================
# WHAT'S IN THE AAD ACCESS TOKEN (JWT)?
# =============================================================================
# The token App Service receives from Azure AD contains:

{
  "aud": "https://management.azure.com",              # Audience (for Azure Resource Manager)
  "iss": "https://sts.windows.net/{tenant-id}/",      # Issuer (Azure AD)
  "iat": 1706734800,                                   # Issued at (Unix timestamp)
  "exp": 1706738400,                                   # Expires at (4 hours later)
  "sub": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",      # Subject (Principal ID)
  "tid": "11111111-2222-3333-4444-555555555555",      # Tenant ID
  "oid": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",      # Object ID (same as Principal ID)
  "appid": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",    # Application ID
  "roles": [],                                          # Assigned roles
  "xms_mirid": "/subscriptions/.../resourceGroups/rg-myapp/providers/Microsoft.Web/sites/app-myapi"
}

# =============================================================================
# WHAT'S IN THE ACR REFRESH TOKEN?
# =============================================================================
# After exchange, ACR returns a different token:

{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",         # Short-lived access token (5 min)
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",        # Long-lived refresh token (hours)
  "token_type": "Bearer",
  "expires_in": 300,                                    # Access token valid for 5 minutes
  "scope": "repository:myapi:pull"                     # Allowed operations
}

# The access_token is used for actual pull operations
# The refresh_token can be used to get new access tokens without re-authenticating
```

**Security Benefits:**

```
┌────────────────────────────────────────────────────────────────────┐
│           MANAGED IDENTITY vs OTHER AUTHENTICATION METHODS         │
└────────────────────────────────────────────────────────────────────┘

                Admin Creds    Service Principal   Managed Identity
                ───────────    ─────────────────   ────────────────
Credentials     ❌ Static        ❌ Client Secret    ✅ None stored
stored in       password       needs secure
config          stored         storage

Rotation        ❌ Manual        ❌ Manual           ✅ Automatic
                rotation       rotation required   by Azure
                needed

Secret          ❌ Can leak      ❌ Can leak if      ✅ No secrets
leakage         if exposed     code/config         to leak
risk            in logs/code   compromised

Audit trail     ⚠️  Limited      ✅ Full audit       ✅ Full audit
                               trail               trail + identity
                                                   attribution

Revocation      ⚠️  Regenerate   ✅ Delete SP        ✅ Remove role
                password       or rotate secret    assignment

Cross-tenant    ❌ Not           ⚠️  Requires        ❌ Not possible
access          supported      trust setup         (security feature)

Complexity      ✅ Simple        ⚠️  Medium          ✅ Simple
                               (requires SP        (built into
                               management)         Azure)

Cost            ✅ Free          ✅ Free             ✅ Free

Best for        Development    CI/CD Pipelines     Production Azure
                only           External systems    Services
```

#### Authentication Setup in Azure DevOps

**Creating Service Connection:**

1. **In Azure DevOps:**
   - Go to Project Settings → Service Connections
   - Click "New Service Connection"
   - Select "Docker Registry"
   - Choose "Azure Container Registry"
   - Select your ACR
   - Name it (e.g., "ACR-MyApp")
   
2. **Behind the scenes:**
   ```bash
   # Azure DevOps creates/uses a Service Principal
   # with these permissions on your ACR:
   
   Role: AcrPush  (allows push and pull)
   Scope: /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.ContainerRegistry/registries/{acr-name}
   ```

3. **In your pipeline:**
   ```yaml
   - task: Docker@2
     inputs:
       containerRegistry: 'ACR-MyApp'  # Reference by name
       # Azure DevOps automatically:
       # - Retrieves Service Principal credentials
       # - Logs in to ACR
       # - Executes docker commands
   ```

---

### Continuous Deployment Setup

#### Enable CI/CD with Webhooks

```bash
# =============================================================================
# CONTINUOUS DEPLOYMENT FROM ACR TO APP SERVICE
# =============================================================================
# When new image is pushed to ACR, automatically deploy to App Service

# 1. Enable continuous deployment on App Service
az webapp deployment container config \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --enable-cd true

# 2. Get webhook URL
WEBHOOK_URL=$(az webapp deployment container show-cd-url \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query CI_CD_URL \
  --output tsv)

# 3. Create webhook in ACR
az acr webhook create \
  --registry $ACR_NAME \
  --name appservicewebhook \
  --actions push \
  --uri $WEBHOOK_URL \
  --scope $IMAGE_NAME:*

# 4. Test webhook
az acr webhook ping --name appservicewebhook --registry $ACR_NAME

# 5. View webhook logs
az acr webhook list-events --name appservicewebhook --registry $ACR_NAME
```

#### Webhook Flow

```
┌─────────────┐    1. Push    ┌─────────────┐    2. Webhook    ┌─────────────┐
│   Azure     │──────────────▶│     ACR     │─────Trigger─────▶│ App Service │
│   Pipeline  │               │             │                  │             │
└─────────────┘               └─────────────┘                  └─────────────┘
                                      │                              │
                                      │         3. Pull Image         │
                                      └──────────────────────────────┘
                                            4. Deploy & Restart
```

---

### Monitoring & Troubleshooting

#### View Deployment Logs

```bash
# App Service logs
az webapp log tail \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP

# Download logs
az webapp log download \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --log-file appservice-logs.zip

# Container Apps logs
az containerapp logs show \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --follow

# ACR task logs (if using ACR tasks)
az acr task logs --registry $ACR_NAME
```

#### Common Issues and Solutions

**1. Authentication Failed**
```bash
# Error: "Failed to pull image from ACR"

# Solution 1: Verify Managed Identity has AcrPull role
az role assignment list \
  --assignee <app-service-principal-id> \
  --scope <acr-resource-id>

# Solution 2: Check ACR admin credentials are correct
az acr credential show --name $ACR_NAME

# Solution 3: Test ACR login manually
docker login $ACR_NAME.azurecr.io
```

**2. Image Not Found**
```bash
# Error: "manifest unknown"

# Check if image exists in ACR
az acr repository show-tags \
  --name $ACR_NAME \
  --repository $IMAGE_NAME

# Verify exact image name in App Service config
az webapp config show \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "[linuxFxVersion, appSettings]"
```

**3. Container Fails to Start**
```bash
# Check container logs
az webapp log tail --name $APP_SERVICE_NAME --resource-group $RESOURCE_GROUP

# Verify port configuration
az webapp config appsettings list \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "[?name=='WEBSITES_PORT']"

# Check health probe
az webapp config show \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "healthCheckPath"
```

**4. Slow Deployments**
```bash
# Enable ACR geo-replication for faster pulls
az acr replication create \
  --registry $ACR_NAME \
  --location westeurope

# Use smaller base images (Alpine)
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine

# Implement proper layer caching in Dockerfile
```

---

### Complete Example: End-to-End Workflow

#### Project Structure
```
MyApi/
├── src/
│   └── MyApi/
│       ├── MyApi.csproj
│       ├── Program.cs
│       └── Controllers/
├── Dockerfile
├── .dockerignore
├── azure-pipelines.yml
└── scripts/
    ├── deploy-acr.sh
    └── deploy-appservice.sh
```

#### Dockerfile (Optimized for Azure)

```dockerfile
# Optimized for Azure deployment
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["src/MyApi/MyApi.csproj", "src/MyApi/"]
RUN dotnet restore "src/MyApi/MyApi.csproj"

COPY . .
WORKDIR "/src/src/MyApi"
RUN dotnet build "MyApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "MyApi.csproj" -c Release -o /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Install curl for health checks
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

COPY --from=publish /app/publish .

# Azure App Service expects port 8080 for non-root containers
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
  CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "MyApi.dll"]
```

#### Deployment Script (deploy.sh)

```bash
#!/bin/bash
# =============================================================================
# Complete deployment script for Azure
# =============================================================================

set -e  # Exit on error

# Configuration
RESOURCE_GROUP="rg-myapp-prod"
LOCATION="eastus"
ACR_NAME="myappacr"
APP_SERVICE_PLAN="plan-myapp"
APP_SERVICE_NAME="app-myapi"
IMAGE_NAME="myapi"
IMAGE_TAG="${1:-latest}"  # Use argument or default to 'latest'

echo "🚀 Starting deployment process..."

# 1. Build Docker image
echo "📦 Building Docker image..."
docker build -t $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG .

# 2. Login to ACR
echo "🔐 Logging in to Azure Container Registry..."
az acr login --name $ACR_NAME

# 3. Push image to ACR
echo "⬆️  Pushing image to ACR..."
docker push $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG

# 4. Update App Service
echo "🔄 Updating App Service..."
az webapp config container set \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --docker-custom-image-name $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG

# 5. Restart App Service
echo "♻️  Restarting App Service..."
az webapp restart \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP

# 6. Wait for deployment
echo "⏳ Waiting for deployment to complete..."
sleep 30

# 7. Health check
echo "🏥 Performing health check..."
APP_URL=$(az webapp show \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query defaultHostName \
  --output tsv)

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://$APP_URL/health)

if [ $HTTP_STATUS -eq 200 ]; then
  echo "✅ Deployment successful!"
  echo "🌐 Application URL: https://$APP_URL"
else
  echo "❌ Deployment failed! Health check returned: $HTTP_STATUS"
  exit 1
fi
```

---

### Best Practices Summary

#### Security
✅ **Use Managed Identity** instead of admin credentials  
✅ **Enable Microsoft Defender for ACR** for vulnerability scanning  
✅ **Use private endpoints** for ACR in production  
✅ **Implement network isolation** with VNET integration  
✅ **Rotate secrets regularly** if using admin credentials  
✅ **Use Azure Key Vault** for sensitive configuration  

#### Performance
✅ **Enable ACR geo-replication** for multi-region deployments  
✅ **Use image caching** with proper layer ordering  
✅ **Implement health checks** for zero-downtime deployments  
✅ **Use slot deployments** in App Service for staging  
✅ **Monitor ACR metrics** (storage, pull/push counts)  

#### Operations
✅ **Tag images with version numbers**, not just 'latest'  
✅ **Implement automated testing** in CI/CD pipeline  
✅ **Use Application Insights** for monitoring  
✅ **Set up alerts** for deployment failures  
✅ **Document rollback procedures**  
✅ **Use staging environments** before production  

#### Cost Optimization
✅ **Delete unused images** regularly  
✅ **Use retention policies** in ACR  
✅ **Choose appropriate SKU** (Basic/Standard/Premium)  
✅ **Monitor resource consumption**  
✅ **Use Azure Cost Management** for tracking  

---

## Azure Functions with Docker

### Overview

Azure Functions supports custom Docker containers, allowing you to:
- Use custom base images and runtime versions
- Install additional system dependencies
- Have full control over the runtime environment
- Deploy the same container to multiple environments
- Use languages/versions not natively supported by Azure Functions

**When to Use Docker with Azure Functions:**
- ✅ Need specific OS-level dependencies
- ✅ Want consistent deployment across environments
- ✅ Require specific runtime versions
- ✅ Need to test locally exactly as it runs in Azure
- ✅ Want to use unsupported language versions

---

### Approach 1: Using Azure Functions Base Images

#### Step 1: Create Function App with Dockerfile

```bash
# =============================================================================
# CREATE .NET 8 ISOLATED FUNCTION APP WITH DOCKER SUPPORT
# =============================================================================

# Install Azure Functions Core Tools (if not installed)
# Windows (requires admin):
# npm install -g azure-functions-core-tools@4 --unsafe-perm true

# Linux/Mac:
# npm install -g azure-functions-core-tools@4

# Create new Function App project
mkdir MyFunctionApp
cd MyFunctionApp

# Initialize Functions project with Docker support
# --docker flag generates a Dockerfile
func init --worker-runtime dotnet-isolated --target-framework net8.0 --docker

# Project structure created:
# MyFunctionApp/
# ├── MyFunctionApp.csproj
# ├── Program.cs
# ├── host.json
# ├── local.settings.json
# ├── .gitignore
# └── Dockerfile  ← Generated automatically

# Create a sample HTTP trigger function
func new --template "HTTP trigger" --name HttpTrigger --authlevel function
```

#### Step 2: Examine Generated Dockerfile

```dockerfile
# =============================================================================
# AZURE FUNCTIONS DOCKERFILE (Generated by func init --docker)
# =============================================================================
# This is the Dockerfile generated by Azure Functions Core Tools
# It follows best practices for Azure Functions containerization

# -----------------------------------------------------------------------------
# Stage 1: Build - Use Azure Functions SDK image
# -----------------------------------------------------------------------------
# The Azure Functions base image includes:
#   - .NET SDK
#   - Azure Functions Core Tools
#   - Required extensions and dependencies
FROM mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated8.0-build AS installer-env

# Set working directory
WORKDIR /src

# Copy project file first (for layer caching)
COPY ["MyFunctionApp.csproj", "./"]

# Restore NuGet packages
RUN dotnet restore "MyFunctionApp.csproj"

# Copy all source files
COPY . .

# Build and publish the function app
# Note: Functions use publish, not build
RUN dotnet publish "MyFunctionApp.csproj" \
    --output /home/site/wwwroot \
    --configuration Release

# -----------------------------------------------------------------------------
# Stage 2: Runtime - Use Azure Functions runtime image
# -----------------------------------------------------------------------------
# This is a lightweight image with only the runtime
# It knows how to execute Azure Functions
FROM mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated8.0

# Set environment variables required by Azure Functions runtime
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true

# Copy published application from build stage
COPY --from=installer-env ["/home/site/wwwroot", "/home/site/wwwroot"]

# No ENTRYPOINT needed - the base image handles it
# The Azure Functions host will automatically start
```

#### Step 3: Enhanced Dockerfile for Production

```dockerfile
# =============================================================================
# PRODUCTION-READY AZURE FUNCTIONS DOCKERFILE
# =============================================================================
# Enhanced version with security, logging, and monitoring

# -----------------------------------------------------------------------------
# Build Arguments for flexibility
# -----------------------------------------------------------------------------
ARG DOTNET_VERSION=8.0
ARG BUILD_CONFIGURATION=Release

# -----------------------------------------------------------------------------
# Build Stage
# -----------------------------------------------------------------------------
FROM mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated${DOTNET_VERSION}-build AS build

WORKDIR /src

# Copy solution/project files
COPY ["MyFunctionApp.csproj", "./"]
COPY ["Directory.Build.props", "./"]

# Restore with logging
RUN dotnet restore "MyFunctionApp.csproj" \
    --verbosity minimal

# Copy source code
COPY . .

# Build with optimizations
RUN dotnet build "MyFunctionApp.csproj" \
    -c ${BUILD_CONFIGURATION} \
    -o /app/build \
    --no-restore

# -----------------------------------------------------------------------------
# Publish Stage
# -----------------------------------------------------------------------------
FROM build AS publish

RUN dotnet publish "MyFunctionApp.csproj" \
    -c ${BUILD_CONFIGURATION} \
    -o /home/site/wwwroot \
    --no-restore \
    --no-build \
    /p:UseAppHost=false

# -----------------------------------------------------------------------------
# Runtime Stage
# -----------------------------------------------------------------------------
FROM mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated${DOTNET_VERSION} AS final

# Install additional tools for debugging/monitoring
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        procps && \
    rm -rf /var/lib/apt/lists/*

# Set Azure Functions environment variables
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    ASPNETCORE_ENVIRONMENT=Production \
    DOTNET_RUNNING_IN_CONTAINER=true

# Copy published function app
COPY --from=publish ["/home/site/wwwroot", "/home/site/wwwroot"]

# Health check for monitoring
# Check if the Functions host is responsive
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost/admin/host/health || exit 1

# Add metadata labels
LABEL maintainer="your-team@company.com" \
      version="1.0" \
      description="Azure Functions - MyFunctionApp"
```

#### Step 4: Build and Test Locally

```bash
# =============================================================================
# LOCAL DOCKER BUILD AND TEST
# =============================================================================

# Build the Docker image
docker build -t myfunctionapp:latest .

# Run locally with environment variables
docker run -d \
  --name myfunctionapp-local \
  -p 8080:80 \
  -e AzureWebJobsStorage="UseDevelopmentStorage=true" \
  -e FUNCTIONS_WORKER_RUNTIME="dotnet-isolated" \
  myfunctionapp:latest

# Test the function
# Wait for startup (check logs)
docker logs -f myfunctionapp-local

# Once ready, test the HTTP trigger
curl http://localhost:8080/api/HttpTrigger?name=Docker

# Expected response:
# "Hello, Docker. This HTTP triggered function executed successfully."

# View function runtime information
curl http://localhost:8080/admin/host/status

# Stop and remove
docker stop myfunctionapp-local
docker rm myfunctionapp-local
```

---

### Approach 2: Deploy to Azure Function App (Linux Container)

#### Method A: Deploy from Local Docker Image to ACR

```bash
# =============================================================================
# COMPLETE DEPLOYMENT WORKFLOW - LOCAL TO AZURE
# =============================================================================

# Variables
RESOURCE_GROUP="rg-functions-prod"
LOCATION="eastus"
ACR_NAME="myfunctionsacr"
FUNCTION_APP_NAME="func-myapp"
STORAGE_ACCOUNT="stfuncmyapp"
APP_INSIGHTS_NAME="appi-myapp"
IMAGE_NAME="myfunctionapp"
IMAGE_TAG="v1.0.0"

# =============================================================================
# STEP 1: CREATE AZURE RESOURCES
# =============================================================================

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create ACR
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Standard \
  --admin-enabled true

# Create Storage Account (required for Azure Functions)
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS

# Get storage connection string
STORAGE_CONNECTION=$(az storage account show-connection-string \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --query connectionString \
  --output tsv)

# Create Application Insights
az monitor app-insights component create \
  --app $APP_INSIGHTS_NAME \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP

# Get Application Insights key
APP_INSIGHTS_KEY=$(az monitor app-insights component show \
  --app $APP_INSIGHTS_NAME \
  --resource-group $RESOURCE_GROUP \
  --query instrumentationKey \
  --output tsv)

# =============================================================================
# STEP 2: BUILD AND PUSH DOCKER IMAGE TO ACR
# =============================================================================

# Login to ACR
az acr login --name $ACR_NAME

# Build image with ACR name
docker build -t $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG .

# Tag as latest
docker tag $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG \
           $ACR_NAME.azurecr.io/$IMAGE_NAME:latest

# Push to ACR
docker push $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG
docker push $ACR_NAME.azurecr.io/$IMAGE_NAME:latest

# Verify
az acr repository list --name $ACR_NAME --output table
az acr repository show-tags --name $ACR_NAME --repository $IMAGE_NAME --output table

# =============================================================================
# STEP 3: CREATE FUNCTION APP WITH CUSTOM CONTAINER
# =============================================================================

# Get ACR credentials
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value --output tsv)

# Create Function App on Linux Consumption plan
# Note: For containers, we need Premium or Dedicated plan
az functionapp plan create \
  --resource-group $RESOURCE_GROUP \
  --name plan-$FUNCTION_APP_NAME \
  --location $LOCATION \
  --is-linux \
  --sku EP1  # Elastic Premium 1 (supports containers)

# Create Function App with custom container
az functionapp create \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --plan plan-$FUNCTION_APP_NAME \
  --storage-account $STORAGE_ACCOUNT \
  --runtime custom \
  --deployment-container-image-name $ACR_NAME.azurecr.io/$IMAGE_NAME:latest \
  --docker-registry-server-url https://$ACR_NAME.azurecr.io \
  --docker-registry-server-user $ACR_USERNAME \
  --docker-registry-server-password $ACR_PASSWORD

# =============================================================================
# STEP 4: CONFIGURE FUNCTION APP SETTINGS
# =============================================================================

# Configure application settings
az functionapp config appsettings set \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings \
    AzureWebJobsStorage="$STORAGE_CONNECTION" \
    FUNCTIONS_WORKER_RUNTIME="dotnet-isolated" \
    APPINSIGHTS_INSTRUMENTATIONKEY="$APP_INSIGHTS_KEY" \
    DOCKER_ENABLE_CI="true"

# =============================================================================
# STEP 5: ENABLE MANAGED IDENTITY AND GRANT ACR ACCESS
# =============================================================================

# Enable System-Assigned Managed Identity
az functionapp identity assign \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP

# Get Principal ID
PRINCIPAL_ID=$(az functionapp identity show \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --query principalId \
  --output tsv)

# Grant ACR Pull access
ACR_ID=$(az acr show --name $ACR_NAME --query id --output tsv)
az role assignment create \
  --assignee $PRINCIPAL_ID \
  --role AcrPull \
  --scope $ACR_ID

# Update Function App to use Managed Identity for ACR
# (Remove username/password, rely on Managed Identity)
az functionapp config container set \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --docker-custom-image-name $ACR_NAME.azurecr.io/$IMAGE_NAME:latest \
  --docker-registry-server-url https://$ACR_NAME.azurecr.io

# =============================================================================
# STEP 6: VERIFY DEPLOYMENT
# =============================================================================

# Restart Function App
az functionapp restart \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP

# Get Function App URL
FUNCTION_URL=$(az functionapp show \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --query defaultHostName \
  --output tsv)

echo "Function App URL: https://$FUNCTION_URL"

# Get function key
FUNCTION_KEY=$(az functionapp keys list \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --query functionKeys.default \
  --output tsv)

# Test the function
curl "https://$FUNCTION_URL/api/HttpTrigger?code=$FUNCTION_KEY&name=Azure"

# Stream logs
az functionapp log tail \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP
```

#### Method B: Deploy Using Azure Functions Core Tools

```bash
# =============================================================================
# PUBLISH FUNCTION APP WITH CONTAINER USING FUNC CLI
# =============================================================================

# Login to Azure
az login

# Set default subscription
az account set --subscription "Your-Subscription-Name"

# Publish to Azure (builds and deploys in one command)
func azure functionapp publish $FUNCTION_APP_NAME --build remote

# Or publish with specific image
func azure functionapp publish $FUNCTION_APP_NAME \
  --docker-only \
  --image-name $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG
```

---

### Approach 3: CI/CD Pipeline for Azure Functions

#### Azure DevOps Pipeline

```yaml
# azure-pipelines-functions.yml
# =============================================================================
# AZURE PIPELINE FOR FUNCTION APP CONTAINER DEPLOYMENT
# =============================================================================

trigger:
  branches:
    include:
      - main
      - develop

variables:
  # Azure Resources
  azureSubscription: 'Azure-Subscription-Connection'
  resourceGroup: 'rg-functions-prod'
  functionAppName: 'func-myapp'
  
  # ACR Configuration
  dockerRegistryServiceConnection: 'ACR-Functions'
  imageRepository: 'myfunctionapp'
  containerRegistry: 'myfunctionsacr.azurecr.io'
  
  # Build Configuration
  dockerfilePath: '$(Build.SourcesDirectory)/Dockerfile'
  tag: '$(Build.BuildId)'

stages:
# =============================================================================
# STAGE 1: BUILD AND TEST
# =============================================================================
- stage: Build
  displayName: 'Build and Test Function App'
  jobs:
  - job: Build
    displayName: 'Build Job'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    # Restore and build .NET project
    - task: UseDotNet@2
      displayName: 'Install .NET 8 SDK'
      inputs:
        version: '8.x'
    
    - task: DotNetCoreCLI@2
      displayName: 'Restore NuGet Packages'
      inputs:
        command: 'restore'
        projects: '**/*.csproj'
    
    - task: DotNetCoreCLI@2
      displayName: 'Build Function App'
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--configuration Release --no-restore'
    
    # Run unit tests
    - task: DotNetCoreCLI@2
      displayName: 'Run Unit Tests'
      inputs:
        command: 'test'
        projects: '**/*Tests.csproj'
        arguments: '--configuration Release --no-build --collect:"XPlat Code Coverage"'
    
    # Publish test results
    - task: PublishTestResults@2
      displayName: 'Publish Test Results'
      inputs:
        testResultsFormat: 'VSTest'
        testResultsFiles: '**/*.trx'
        mergeTestResults: true

# =============================================================================
# STAGE 2: BUILD AND PUSH DOCKER IMAGE
# =============================================================================
- stage: ContainerBuild
  displayName: 'Build and Push Container'
  dependsOn: Build
  condition: succeeded()
  jobs:
  - job: Docker
    displayName: 'Docker Build and Push'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    # Build and push Docker image to ACR
    - task: Docker@2
      displayName: 'Build and Push Docker Image'
      inputs:
        command: buildAndPush
        repository: $(imageRepository)
        dockerfile: $(dockerfilePath)
        containerRegistry: $(dockerRegistryServiceConnection)
        tags: |
          $(tag)
          latest
    
    # Scan image for vulnerabilities (optional but recommended)
    - task: Bash@3
      displayName: 'Scan Docker Image'
      inputs:
        targetType: 'inline'
        script: |
          # Using Trivy for vulnerability scanning
          docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy:latest image \
            $(containerRegistry)/$(imageRepository):$(tag) \
            --severity HIGH,CRITICAL \
            --exit-code 0  # Don't fail build, just warn

# =============================================================================
# STAGE 3: DEPLOY TO DEV ENVIRONMENT
# =============================================================================
- stage: DeployDev
  displayName: 'Deploy to Development'
  dependsOn: ContainerBuild
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/develop'))
  jobs:
  - deployment: DeployDev
    displayName: 'Deploy to Dev Function App'
    pool:
      vmImage: 'ubuntu-latest'
    environment: 'development'
    strategy:
      runOnce:
        deploy:
          steps:
          # Update Function App container
          - task: AzureCLI@2
            displayName: 'Update Function App Container'
            inputs:
              azureSubscription: $(azureSubscription)
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                az functionapp config container set \
                  --name $(functionAppName)-dev \
                  --resource-group $(resourceGroup)-dev \
                  --docker-custom-image-name $(containerRegistry)/$(imageRepository):$(tag)
                
                # Restart to apply changes
                az functionapp restart \
                  --name $(functionAppName)-dev \
                  --resource-group $(resourceGroup)-dev
          
          # Wait for deployment to complete
          - task: Bash@3
            displayName: 'Verify Deployment'
            inputs:
              targetType: 'inline'
              script: |
                echo "Waiting for function app to start..."
                sleep 30
                
                # Get function URL
                FUNCTION_URL=$(az functionapp show \
                  --name $(functionAppName)-dev \
                  --resource-group $(resourceGroup)-dev \
                  --query defaultHostName \
                  --output tsv)
                
                echo "Function App URL: https://$FUNCTION_URL"
                
                # Health check
                HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://$FUNCTION_URL/admin/host/health)
                
                if [ $HTTP_STATUS -eq 200 ]; then
                  echo "✅ Deployment successful!"
                else
                  echo "❌ Deployment failed! Health check returned: $HTTP_STATUS"
                  exit 1
                fi

# =============================================================================
# STAGE 4: DEPLOY TO PRODUCTION
# =============================================================================
- stage: DeployProd
  displayName: 'Deploy to Production'
  dependsOn: ContainerBuild
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: DeployProd
    displayName: 'Deploy to Production Function App'
    pool:
      vmImage: 'ubuntu-latest'
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          # Deploy to production with slot swap
          - task: AzureCLI@2
            displayName: 'Deploy to Staging Slot'
            inputs:
              azureSubscription: $(azureSubscription)
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                # Create staging slot if doesn't exist
                az functionapp deployment slot create \
                  --name $(functionAppName) \
                  --resource-group $(resourceGroup) \
                  --slot staging \
                  --configuration-source $(functionAppName) || true
                
                # Update staging slot with new image
                az functionapp config container set \
                  --name $(functionAppName) \
                  --resource-group $(resourceGroup) \
                  --slot staging \
                  --docker-custom-image-name $(containerRegistry)/$(imageRepository):$(tag)
                
                # Restart staging slot
                az functionapp restart \
                  --name $(functionAppName) \
                  --resource-group $(resourceGroup) \
                  --slot staging
          
          # Smoke test staging slot
          - task: Bash@3
            displayName: 'Test Staging Slot'
            inputs:
              targetType: 'inline'
              script: |
                echo "Testing staging slot..."
                sleep 30
                
                # Get staging slot URL
                STAGING_URL=$(az functionapp show \
                  --name $(functionAppName) \
                  --resource-group $(resourceGroup) \
                  --slot staging \
                  --query defaultHostName \
                  --output tsv)
                
                # Run smoke tests
                # Add your smoke test logic here
                echo "Smoke tests passed for https://$STAGING_URL"
          
          # Swap slots (Blue-Green deployment)
          - task: AzureFunctionAppContainer@1
            displayName: 'Swap Staging to Production'
            inputs:
              azureSubscription: $(azureSubscription)
              appName: $(functionAppName)
              resourceGroupName: $(resourceGroup)
              slotName: 'staging'
              deployToSlotOrASE: true
              action: 'Slot Swap'
              sourceSlot: 'staging'
              targetSlot: 'production'
          
          # Verify production deployment
          - task: Bash@3
            displayName: 'Verify Production Deployment'
            inputs:
              targetType: 'inline'
              script: |
                echo "Verifying production deployment..."
                sleep 20
                
                PROD_URL=$(az functionapp show \
                  --name $(functionAppName) \
                  --resource-group $(resourceGroup) \
                  --query defaultHostName \
                  --output tsv)
                
                HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://$PROD_URL/admin/host/health)
                
                if [ $HTTP_STATUS -eq 200 ]; then
                  echo "✅ Production deployment successful!"
                  echo "🌐 Function App URL: https://$PROD_URL"
                else
                  echo "❌ Production deployment failed! Rolling back..."
                  # Swap back to previous version
                  az functionapp deployment slot swap \
                    --name $(functionAppName) \
                    --resource-group $(resourceGroup) \
                    --slot production \
                    --target-slot staging
                  exit 1
                fi
```

---

### Approach 4: GitHub Actions Workflow

```yaml
# .github/workflows/deploy-functions.yml
name: Build and Deploy Azure Function

on:
  push:
    branches:
      - main
      - develop
  pull_request:
    branches:
      - main

env:
  AZURE_FUNCTIONAPP_NAME: 'func-myapp'
  ACR_NAME: 'myfunctionsacr'
  IMAGE_NAME: 'myfunctionapp'
  RESOURCE_GROUP: 'rg-functions-prod'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    # Checkout code
    - name: 'Checkout GitHub Action'
      uses: actions/checkout@v4
    
    # Login to Azure
    - name: 'Login to Azure'
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    # Login to ACR
    - name: 'Login to Azure Container Registry'
      uses: azure/docker-login@v1
      with:
        login-server: ${{ env.ACR_NAME }}.azurecr.io
        username: ${{ secrets.ACR_USERNAME }}
        password: ${{ secrets.ACR_PASSWORD }}
    
    # Build and push Docker image
    - name: 'Build and Push Docker Image'
      run: |
        docker build -t ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:${{ github.sha }} .
        docker tag ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:${{ github.sha }} \
                   ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:latest
        docker push ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:${{ github.sha }}
        docker push ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:latest
    
    # Deploy to Azure Functions
    - name: 'Deploy to Azure Functions'
      uses: Azure/functions-container-action@v1
      with:
        app-name: ${{ env.AZURE_FUNCTIONAPP_NAME }}
        image: ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:${{ github.sha }}
```

---

### Best Practices for Azure Functions with Docker

#### 1. Dockerfile Optimization

```dockerfile
# Use specific version tags (not 'latest')
FROM mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated8.0

# Keep images small
# - Use multi-stage builds
# - Clean up package manager caches
# - Only install required dependencies

# Set appropriate timeout for long-running functions
ENV AzureFunctionsJobHost__functionTimeout=00:10:00
```

#### 2. Configuration Management

```bash
# Use Azure Key Vault for secrets
az functionapp config appsettings set \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings \
    @Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/apikey/)
```

#### 3. Monitoring and Logging

```csharp
// Program.cs
using Microsoft.Extensions.Hosting;
using Microsoft.ApplicationInsights.Extensibility;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .ConfigureServices(services =>
    {
        // Add Application Insights
        services.AddApplicationInsightsTelemetryWorkerService();
        services.ConfigureFunctionsApplicationInsights();
    })
    .Build();

host.Run();
```

#### 4. Testing Containerized Functions Locally

```bash
# Run with Azure Storage Emulator (Azurite)
docker run -d \
  --name azurite \
  -p 10000:10000 \
  -p 10001:10001 \
  -p 10002:10002 \
  mcr.microsoft.com/azure-storage/azurite

# Run Function App pointing to Azurite
docker run -d \
  --name myfunctionapp \
  --link azurite \
  -p 8080:80 \
  -e AzureWebJobsStorage="DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://azurite:10000/devstoreaccount1;" \
  myfunctionapp:latest
```

---

## Security Best Practices

### 1. **Non-Root User**

```dockerfile
# Create and use non-root user
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Create user and group
RUN groupadd -r appuser --gid=1000 \
    && useradd -r -g appuser --uid=1000 --create-home --shell /bin/bash appuser

# Copy application
COPY --from=publish --chown=appuser:appuser /app/publish .

# Switch to non-root user
USER appuser

ENTRYPOINT ["dotnet", "MyApi.dll"]
```

### 2. **Minimal Base Images**

```dockerfile
# Use distroless for smallest attack surface
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app/publish

# Use distroless runtime (no shell, no package manager)
FROM gcr.io/distroless/dotnet8-runtime
WORKDIR /app
COPY --from=build /app/publish .
USER nonroot:nonroot
ENTRYPOINT ["MyApi.dll"]
```

### 3. **Security Scanning**

```bash
# Scan image for vulnerabilities with Trivy
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image myapi:latest

# Scan with Snyk
snyk container test myapi:latest --file=Dockerfile

# Scan with Docker Scout
docker scout cves myapi:latest
```

### 4. **Secrets Management**

```csharp
// Use Azure Key Vault for secrets
// Program.cs
var builder = WebApplication.CreateBuilder(args);

if (builder.Environment.IsProduction())
{
    var keyVaultEndpoint = builder.Configuration["KeyVault:Endpoint"];
    
    builder.Configuration.AddAzureKeyVault(
        new Uri(keyVaultEndpoint),
        new DefaultAzureCredential());
}

builder.Services.AddControllers();
var app = builder.Build();
app.MapControllers();
app.Run();
```

```dockerfile
# Use build secrets (never baked into image)
# docker buildx build --secret id=nuget,src=nuget.config -t myapi .
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Mount secret without copying into layer
RUN --mount=type=secret,id=nuget,target=/root/.nuget/NuGet/NuGet.Config \
    dotnet restore
```

#### **Secret Provider Class Implementation**

```csharp
// ISecretProvider.cs
public interface ISecretProvider
{
    Task<string?> GetSecretAsync(string secretName, CancellationToken cancellationToken = default);
    Task<Dictionary<string, string>> GetSecretsAsync(string[] secretNames, CancellationToken cancellationToken = default);
    Task<bool> SetSecretAsync(string secretName, string secretValue, CancellationToken cancellationToken = default);
    Task<bool> DeleteSecretAsync(string secretName, CancellationToken cancellationToken = default);
}

// SecretProviderOptions.cs
public class SecretProviderOptions
{
    public string Provider { get; set; } = "Environment"; // Environment, AzureKeyVault, AwsSecretsManager, HashiCorpVault, DockerSecrets
    public string? Endpoint { get; set; }
    public string? TenantId { get; set; }
    public string? ClientId { get; set; }
    public string? ClientSecret { get; set; }
    public bool UseDefaultCredentials { get; set; } = true;
    public int CacheDurationMinutes { get; set; } = 5;
    public string? DockerSecretsPath { get; set; } = "/run/secrets";
}

// AzureKeyVaultSecretProvider.cs
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

public class AzureKeyVaultSecretProvider : ISecretProvider
{
    private readonly SecretClient _secretClient;
    private readonly IMemoryCache _cache;
    private readonly ILogger<AzureKeyVaultSecretProvider> _logger;
    private readonly SecretProviderOptions _options;

    public AzureKeyVaultSecretProvider(
        IOptions<SecretProviderOptions> options,
        IMemoryCache cache,
        ILogger<AzureKeyVaultSecretProvider> logger)
    {
        _options = options.Value;
        _cache = cache;
        _logger = logger;

        var credential = _options.UseDefaultCredentials
            ? new DefaultAzureCredential()
            : new ClientSecretCredential(_options.TenantId, _options.ClientId, _options.ClientSecret);

        _secretClient = new SecretClient(new Uri(_options.Endpoint!), credential);
    }

    public async Task<string?> GetSecretAsync(string secretName, CancellationToken cancellationToken = default)
    {
        var cacheKey = $"secret_{secretName}";
        
        if (_cache.TryGetValue(cacheKey, out string? cachedValue))
        {
            _logger.LogDebug("Retrieved secret {SecretName} from cache", secretName);
            return cachedValue;
        }

        try
        {
            var secret = await _secretClient.GetSecretAsync(secretName, cancellationToken: cancellationToken);
            var value = secret.Value.Value;

            _cache.Set(cacheKey, value, TimeSpan.FromMinutes(_options.CacheDurationMinutes));
            _logger.LogInformation("Retrieved secret {SecretName} from Azure Key Vault", secretName);

            return value;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving secret {SecretName} from Azure Key Vault", secretName);
            return null;
        }
    }

    public async Task<Dictionary<string, string>> GetSecretsAsync(string[] secretNames, CancellationToken cancellationToken = default)
    {
        var secrets = new Dictionary<string, string>();
        
        foreach (var secretName in secretNames)
        {
            var value = await GetSecretAsync(secretName, cancellationToken);
            if (value != null)
            {
                secrets[secretName] = value;
            }
        }

        return secrets;
    }

    public async Task<bool> SetSecretAsync(string secretName, string secretValue, CancellationToken cancellationToken = default)
    {
        try
        {
            await _secretClient.SetSecretAsync(secretName, secretValue, cancellationToken);
            _cache.Remove($"secret_{secretName}");
            _logger.LogInformation("Set secret {SecretName} in Azure Key Vault", secretName);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error setting secret {SecretName} in Azure Key Vault", secretName);
            return false;
        }
    }

    public async Task<bool> DeleteSecretAsync(string secretName, CancellationToken cancellationToken = default)
    {
        try
        {
            await _secretClient.StartDeleteSecretAsync(secretName, cancellationToken);
            _cache.Remove($"secret_{secretName}");
            _logger.LogInformation("Deleted secret {SecretName} from Azure Key Vault", secretName);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting secret {SecretName} from Azure Key Vault", secretName);
            return false;
        }
    }
}

// DockerSecretsProvider.cs
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

public class DockerSecretsProvider : ISecretProvider
{
    private readonly ILogger<DockerSecretsProvider> _logger;
    private readonly SecretProviderOptions _options;

    public DockerSecretsProvider(
        IOptions<SecretProviderOptions> options,
        ILogger<DockerSecretsProvider> logger)
    {
        _options = options.Value;
        _logger = logger;
    }

    public Task<string?> GetSecretAsync(string secretName, CancellationToken cancellationToken = default)
    {
        try
        {
            var secretPath = Path.Combine(_options.DockerSecretsPath ?? "/run/secrets", secretName);
            
            if (!File.Exists(secretPath))
            {
                _logger.LogWarning("Docker secret {SecretName} not found at {Path}", secretName, secretPath);
                return Task.FromResult<string?>(null);
            }

            var value = File.ReadAllText(secretPath).Trim();
            _logger.LogInformation("Retrieved Docker secret {SecretName}", secretName);
            return Task.FromResult<string?>(value);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error reading Docker secret {SecretName}", secretName);
            return Task.FromResult<string?>(null);
        }
    }

    public async Task<Dictionary<string, string>> GetSecretsAsync(string[] secretNames, CancellationToken cancellationToken = default)
    {
        var secrets = new Dictionary<string, string>();
        
        foreach (var secretName in secretNames)
        {
            var value = await GetSecretAsync(secretName, cancellationToken);
            if (value != null)
            {
                secrets[secretName] = value;
            }
        }

        return secrets;
    }

    public Task<bool> SetSecretAsync(string secretName, string secretValue, CancellationToken cancellationToken = default)
    {
        _logger.LogWarning("Docker secrets are read-only. Cannot set secret {SecretName}", secretName);
        return Task.FromResult(false);
    }

    public Task<bool> DeleteSecretAsync(string secretName, CancellationToken cancellationToken = default)
    {
        _logger.LogWarning("Docker secrets are read-only. Cannot delete secret {SecretName}", secretName);
        return Task.FromResult(false);
    }
}

// EnvironmentSecretProvider.cs
using Microsoft.Extensions.Logging;

public class EnvironmentSecretProvider : ISecretProvider
{
    private readonly ILogger<EnvironmentSecretProvider> _logger;

    public EnvironmentSecretProvider(ILogger<EnvironmentSecretProvider> logger)
    {
        _logger = logger;
    }

    public Task<string?> GetSecretAsync(string secretName, CancellationToken cancellationToken = default)
    {
        var value = Environment.GetEnvironmentVariable(secretName);
        
        if (value != null)
        {
            _logger.LogDebug("Retrieved secret {SecretName} from environment variables", secretName);
        }
        else
        {
            _logger.LogWarning("Secret {SecretName} not found in environment variables", secretName);
        }

        return Task.FromResult(value);
    }

    public async Task<Dictionary<string, string>> GetSecretsAsync(string[] secretNames, CancellationToken cancellationToken = default)
    {
        var secrets = new Dictionary<string, string>();
        
        foreach (var secretName in secretNames)
        {
            var value = await GetSecretAsync(secretName, cancellationToken);
            if (value != null)
            {
                secrets[secretName] = value;
            }
        }

        return secrets;
    }

    public Task<bool> SetSecretAsync(string secretName, string secretValue, CancellationToken cancellationToken = default)
    {
        Environment.SetEnvironmentVariable(secretName, secretValue);
        _logger.LogInformation("Set environment variable {SecretName}", secretName);
        return Task.FromResult(true);
    }

    public Task<bool> DeleteSecretAsync(string secretName, CancellationToken cancellationToken = default)
    {
        Environment.SetEnvironmentVariable(secretName, null);
        _logger.LogInformation("Deleted environment variable {SecretName}", secretName);
        return Task.FromResult(true);
    }
}

// HashiCorpVaultSecretProvider.cs
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Net.Http.Json;

public class HashiCorpVaultSecretProvider : ISecretProvider
{
    private readonly HttpClient _httpClient;
    private readonly IMemoryCache _cache;
    private readonly ILogger<HashiCorpVaultSecretProvider> _logger;
    private readonly SecretProviderOptions _options;

    public HashiCorpVaultSecretProvider(
        HttpClient httpClient,
        IOptions<SecretProviderOptions> options,
        IMemoryCache cache,
        ILogger<HashiCorpVaultSecretProvider> logger)
    {
        _httpClient = httpClient;
        _options = options.Value;
        _cache = cache;
        _logger = logger;

        _httpClient.BaseAddress = new Uri(_options.Endpoint!);
        _httpClient.DefaultRequestHeaders.Add("X-Vault-Token", _options.ClientSecret);
    }

    public async Task<string?> GetSecretAsync(string secretName, CancellationToken cancellationToken = default)
    {
        var cacheKey = $"secret_{secretName}";
        
        if (_cache.TryGetValue(cacheKey, out string? cachedValue))
        {
            return cachedValue;
        }

        try
        {
            var response = await _httpClient.GetAsync($"v1/secret/data/{secretName}", cancellationToken);
            response.EnsureSuccessStatusCode();

            var vaultResponse = await response.Content.ReadFromJsonAsync<VaultResponse>(cancellationToken: cancellationToken);
            var value = vaultResponse?.Data?.Data?.FirstOrDefault().Value?.ToString();

            if (value != null)
            {
                _cache.Set(cacheKey, value, TimeSpan.FromMinutes(_options.CacheDurationMinutes));
                _logger.LogInformation("Retrieved secret {SecretName} from HashiCorp Vault", secretName);
            }

            return value;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving secret {SecretName} from HashiCorp Vault", secretName);
            return null;
        }
    }

    public async Task<Dictionary<string, string>> GetSecretsAsync(string[] secretNames, CancellationToken cancellationToken = default)
    {
        var secrets = new Dictionary<string, string>();
        
        foreach (var secretName in secretNames)
        {
            var value = await GetSecretAsync(secretName, cancellationToken);
            if (value != null)
            {
                secrets[secretName] = value;
            }
        }

        return secrets;
    }

    public async Task<bool> SetSecretAsync(string secretName, string secretValue, CancellationToken cancellationToken = default)
    {
        try
        {
            var content = JsonContent.Create(new { data = new Dictionary<string, string> { [secretName] = secretValue } });
            var response = await _httpClient.PostAsync($"v1/secret/data/{secretName}", content, cancellationToken);
            response.EnsureSuccessStatusCode();
            
            _cache.Remove($"secret_{secretName}");
            _logger.LogInformation("Set secret {SecretName} in HashiCorp Vault", secretName);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error setting secret {SecretName} in HashiCorp Vault", secretName);
            return false;
        }
    }

    public Task<bool> DeleteSecretAsync(string secretName, CancellationToken cancellationToken = default)
    {
        _logger.LogWarning("Delete not implemented for HashiCorp Vault provider");
        return Task.FromResult(false);
    }

    private class VaultResponse
    {
        public VaultData? Data { get; set; }
    }

    private class VaultData
    {
        public Dictionary<string, object>? Data { get; set; }
    }
}

// SecretProviderFactory.cs
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;

public class SecretProviderFactory
{
    private readonly IServiceProvider _serviceProvider;

    public SecretProviderFactory(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public ISecretProvider CreateProvider()
    {
        var options = _serviceProvider.GetRequiredService<IOptions<SecretProviderOptions>>().Value;

        return options.Provider.ToLower() switch
        {
            "azurekeyvault" => _serviceProvider.GetRequiredService<AzureKeyVaultSecretProvider>(),
            "dockersecrets" => _serviceProvider.GetRequiredService<DockerSecretsProvider>(),
            "hashicorpvault" => _serviceProvider.GetRequiredService<HashiCorpVaultSecretProvider>(),
            "environment" => _serviceProvider.GetRequiredService<EnvironmentSecretProvider>(),
            _ => _serviceProvider.GetRequiredService<EnvironmentSecretProvider>()
        };
    }
}

// ServiceCollectionExtensions.cs
using Microsoft.Extensions.DependencyInjection;

public static class SecretProviderExtensions
{
    public static IServiceCollection AddSecretProvider(
        this IServiceCollection services,
        Action<SecretProviderOptions> configureOptions)
    {
        services.Configure(configureOptions);
        services.AddMemoryCache();
        services.AddHttpClient<HashiCorpVaultSecretProvider>();
        
        services.AddSingleton<AzureKeyVaultSecretProvider>();
        services.AddSingleton<DockerSecretsProvider>();
        services.AddSingleton<EnvironmentSecretProvider>();
        services.AddSingleton<HashiCorpVaultSecretProvider>();
        services.AddSingleton<SecretProviderFactory>();
        
        services.AddSingleton<ISecretProvider>(sp => 
            sp.GetRequiredService<SecretProviderFactory>().CreateProvider());

        return services;
    }
}

// Usage in Program.cs
var builder = WebApplication.CreateBuilder(args);

// Configure secret provider
builder.Services.AddSecretProvider(options =>
{
    builder.Configuration.GetSection("SecretProvider").Bind(options);
    
    // Override based on environment
    if (builder.Environment.IsDevelopment())
    {
        options.Provider = "Environment";
    }
    else if (Environment.GetEnvironmentVariable("KUBERNETES_SERVICE_HOST") != null)
    {
        // Running in Kubernetes
        options.Provider = "DockerSecrets";
    }
    else
    {
        // Running in Azure
        options.Provider = "AzureKeyVault";
        options.Endpoint = builder.Configuration["KeyVault:Endpoint"];
    }
});

var app = builder.Build();

// Example usage in a service
public class MyService
{
    private readonly ISecretProvider _secretProvider;

    public MyService(ISecretProvider secretProvider)
    {
        _secretProvider = secretProvider;
    }

    public async Task DoWorkAsync()
    {
        // Get single secret
        var apiKey = await _secretProvider.GetSecretAsync("ApiKey");
        
        // Get multiple secrets
        var secrets = await _secretProvider.GetSecretsAsync(new[] 
        { 
            "DatabasePassword", 
            "RedisPassword", 
            "JwtSecret" 
        });
        
        // Use the secrets
        var dbPassword = secrets["DatabasePassword"];
    }
}
```

#### **Configuration**

```json
// appsettings.json
{
  "SecretProvider": {
    "Provider": "AzureKeyVault",
    "Endpoint": "https://myvault.vault.azure.net/",
    "UseDefaultCredentials": true,
    "CacheDurationMinutes": 5
  }
}

// appsettings.Development.json
{
  "SecretProvider": {
    "Provider": "Environment",
    "CacheDurationMinutes": 1
  }
}

// appsettings.Production.json
{
  "SecretProvider": {
    "Provider": "AzureKeyVault",
    "Endpoint": "${KEYVAULT_ENDPOINT}",
    "UseDefaultCredentials": true,
    "CacheDurationMinutes": 10
  }
}
```

#### **Docker Integration**

```dockerfile
# =============================================================================
# DOCKERFILE WITH SECRET PROVIDER SUPPORT
# =============================================================================
# Supports multiple secret providers:
#   - Azure Key Vault (with Managed Identity)
#   - Docker Secrets
#   - Kubernetes Secrets
#   - Environment Variables
# =============================================================================

# -----------------------------------------------------------------------------
# Build stage - standard multi-stage build
# -----------------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy and restore
COPY ["MyApi/MyApi.csproj", "MyApi/"]
RUN dotnet restore "MyApi/MyApi.csproj"

# Build application
COPY . .
WORKDIR "/src/MyApi"
RUN dotnet publish -c Release -o /app/publish

# -----------------------------------------------------------------------------
# Final runtime stage with secret management support
# -----------------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final

WORKDIR /app

# -----------------------------------------------------------------------------
# Install Azure CLI for Managed Identity support
# -----------------------------------------------------------------------------
# RUN: Chain multiple commands
# Why install Azure CLI?
#   - Enables Azure Managed Identity authentication
#   - Used by DefaultAzureCredential in code
#   - Allows containerized apps to authenticate with Azure services
#   - No need to store credentials in container
# 
# apt-get update: Refresh package repository
# apt-get install -y curl: Install curl (for downloading)
# curl -sL https://aka.ms/InstallAzureCLIDeb:
#   -sL: Silent, follow redirects
#   Downloads Azure CLI installation script
# | bash: Pipe to bash for execution
# rm -rf /var/lib/apt/lists/*: Clean up (reduce image size)
RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    rm -rf /var/lib/apt/lists/*

# Copy published application
COPY --from=build /app/publish .

# -----------------------------------------------------------------------------
# Environment variables for secret provider configuration
# -----------------------------------------------------------------------------
# ENV: Configure which secret provider to use
# Application reads these at startup to determine secret source

# SecretProvider__Provider: Which provider to use
#   Options: DockerSecrets, AzureKeyVault, Environment, HashiCorpVault
#   Default here: DockerSecrets (for Docker/Kubernetes)
ENV SecretProvider__Provider=DockerSecrets

# SecretProvider__DockerSecretsPath: Location of Docker/Kubernetes secrets
#   Docker Swarm: /run/secrets (standard location)
#   Kubernetes: Can be custom mounted path (e.g., /mnt/secrets)
#   Secrets are mounted as read-only files at this location
ENV SecretProvider__DockerSecretsPath=/run/secrets

# -----------------------------------------------------------------------------
# Entry point
# -----------------------------------------------------------------------------
# At runtime:
#   1. App reads SecretProvider__Provider environment variable
#   2. Initializes appropriate secret provider
#   3. Loads secrets from configured source
#   4. Uses secrets for database connections, API keys, etc.
ENTRYPOINT ["dotnet", "MyApi.dll"]
```

```yaml
# docker-compose.yml with Docker Secrets
version: '3.8'

services:
  api:
    build: .
    secrets:
      - db_password
      - api_key
      - jwt_secret
    environment:
      - SecretProvider__Provider=DockerSecrets
      - ConnectionStrings__DefaultConnection=Server=db;Database=MyDb;User=sa;Password=/run/secrets/db_password
    ports:
      - "5000:80"

secrets:
  db_password:
    file: ./secrets/db_password.txt
  api_key:
    file: ./secrets/api_key.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt
```

```yaml
# kubernetes-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: api-secrets
  namespace: production
type: Opaque
stringData:
  db-password: "YourSecurePassword123!"
  api-key: "your-api-key-here"
  jwt-secret: "your-jwt-secret-here"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapi
spec:
  template:
    spec:
      containers:
      - name: myapi
        image: myapi:latest
        env:
        - name: SecretProvider__Provider
          value: "DockerSecrets"
        - name: SecretProvider__DockerSecretsPath
          value: "/mnt/secrets"
        volumeMounts:
        - name: secrets
          mountPath: /mnt/secrets
          readOnly: true
      volumes:
      - name: secrets
        secret:
          secretName: api-secrets
          items:
          - key: db-password
            path: db_password
          - key: api-key
            path: api_key
          - key: jwt-secret
            path: jwt_secret
```

#### **Azure Key Vault with Managed Identity**

```yaml
# kubernetes-azure-keyvault.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: myapi-sa
  namespace: production
  annotations:
    azure.workload.identity/client-id: "your-client-id"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapi
spec:
  template:
    metadata:
      labels:
        azure.workload.identity/use: "true"
    spec:
      serviceAccountName: myapi-sa
      containers:
      - name: myapi
        image: myapi:latest
        env:
        - name: SecretProvider__Provider
          value: "AzureKeyVault"
        - name: SecretProvider__Endpoint
          value: "https://myvault.vault.azure.net/"
        - name: SecretProvider__UseDefaultCredentials
          value: "true"
```

### 5. **Network Security**

```yaml
# Docker Compose with network isolation
version: '3.8'

services:
  api:
    networks:
      - frontend
      - backend
    # Only expose necessary ports
    ports:
      - "443:443"  # Only HTTPS

  db:
    networks:
      - backend  # Not accessible from frontend
    # No exposed ports - internal only

networks:
  frontend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
  backend:
    driver: bridge
    internal: true  # No external access
```

### 6. **Read-Only Filesystem**

```yaml
# Kubernetes deployment with read-only root filesystem
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapi
spec:
  template:
    spec:
      containers:
      - name: myapi
        image: myapi:latest
        securityContext:
          readOnlyRootFilesystem: true
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1000
          capabilities:
            drop:
              - ALL
        volumeMounts:
        - name: tmp
          mountPath: /tmp
        - name: app-tmp
          mountPath: /app/tmp
      volumes:
      - name: tmp
        emptyDir: {}
      - name: app-tmp
        emptyDir: {}
```

### 7. **Content Trust & Image Signing**

```bash
# Enable Docker Content Trust
export DOCKER_CONTENT_TRUST=1

# Sign images
docker trust sign myregistry.azurecr.io/myapi:latest

# Verify signature
docker trust inspect myregistry.azurecr.io/myapi:latest
```

### 8. **Security Headers in .NET**

```csharp
// Program.cs
var app = builder.Build();

app.Use(async (context, next) =>
{
    context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
    context.Response.Headers.Add("X-Frame-Options", "DENY");
    context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
    context.Response.Headers.Add("Referrer-Policy", "no-referrer");
    context.Response.Headers.Add("Content-Security-Policy", "default-src 'self'");
    context.Response.Headers.Add("Permissions-Policy", "geolocation=(), microphone=(), camera=()");
    
    await next();
});
```

---

## Performance Optimization

### 1. **Layer Caching Optimization**

```dockerfile
# Optimize layer caching
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy only project files first (cached unless project structure changes)
COPY ["Directory.Build.props", "./"]
COPY ["src/MyApi/MyApi.csproj", "src/MyApi/"]
COPY ["src/MyApi.Core/MyApi.Core.csproj", "src/MyApi.Core/"]
COPY ["src/MyApi.Infrastructure/MyApi.Infrastructure.csproj", "src/MyApi.Infrastructure/"]

# Restore (cached unless csproj changes)
RUN dotnet restore "src/MyApi/MyApi.csproj"

# Copy source code (changes frequently)
COPY . .

# Build
WORKDIR "/src/src/MyApi"
RUN dotnet build "MyApi.csproj" -c Release -o /app/build --no-restore

# Publish
FROM build AS publish
RUN dotnet publish "MyApi.csproj" -c Release -o /app/publish --no-restore --no-build
```

### 2. **BuildKit and Caching**

```bash
# Enable BuildKit for better caching
export DOCKER_BUILDKIT=1

# Build with cache mount
docker build \
  --secret id=nuget,src=nuget.config \
  --cache-from myapi:latest \
  --tag myapi:latest .

# Use remote cache
docker buildx build \
  --cache-from type=registry,ref=myregistry.azurecr.io/myapi:buildcache \
  --cache-to type=registry,ref=myregistry.azurecr.io/myapi:buildcache,mode=max \
  --tag myapi:latest \
  --push .
```

### 3. **Multi-Platform Builds**

```bash
# Build for multiple architectures
docker buildx create --name multiplatform --use
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag myregistry.azurecr.io/myapi:latest \
  --push .
```

### 4. **Image Size Optimization**

```dockerfile
# Minimize image size
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app/publish \
    /p:PublishTrimmed=true \
    /p:PublishSingleFile=false \
    /p:EnableCompressionInSingleFile=true

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS final
WORKDIR /app

# Install only required dependencies
RUN apk add --no-cache \
    icu-libs \
    krb5-libs \
    libgcc \
    libintl \
    libssl3 \
    libstdc++ \
    zlib

COPY --from=build /app/publish .

# Remove unnecessary files
RUN find . -name "*.pdb" -delete && \
    find . -name "*.xml" -delete

USER $APP_UID
ENTRYPOINT ["dotnet", "MyApi.dll"]
```

### 5. **Runtime Optimization**

```csharp
// Program.cs - Configure Kestrel for performance
builder.WebHost.ConfigureKestrel(options =>
{
    options.Limits.MaxConcurrentConnections = 100;
    options.Limits.MaxConcurrentUpgradedConnections = 100;
    options.Limits.MaxRequestBodySize = 10 * 1024 * 1024; // 10MB
    options.Limits.MinRequestBodyDataRate = new MinDataRate(
        bytesPerSecond: 100, 
        gracePeriod: TimeSpan.FromSeconds(10));
    options.Limits.MinResponseDataRate = new MinDataRate(
        bytesPerSecond: 100, 
        gracePeriod: TimeSpan.FromSeconds(10));
});

// Add response compression
builder.Services.AddResponseCompression(options =>
{
    options.EnableForHttps = true;
    options.Providers.Add<BrotliCompressionProvider>();
    options.Providers.Add<GzipCompressionProvider>();
});

// Configure response caching
builder.Services.AddResponseCaching(options =>
{
    options.MaximumBodySize = 1024;
    options.UseCaseSensitivePaths = true;
});
```

### 6. **Resource Limits**

```yaml
# docker-compose.yml with resource limits
version: '3.8'

services:
  api:
    image: myapi:latest
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
```

---

## Networking in Docker

### 1. **Network Types**

```bash
# Bridge network (default)
docker network create --driver bridge my-bridge-network

# Host network (container uses host's network stack)
docker run --network host myapi:latest

# Overlay network (multi-host networking for Swarm)
docker network create --driver overlay --attachable my-overlay-network

# Macvlan network (assign MAC address to container)
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  my-macvlan-network
```

### 2. **Custom Bridge Network**

```yaml
# docker-compose.yml
version: '3.8'

services:
  api:
    image: myapi:latest
    networks:
      - frontend
      - backend
    environment:
      - DatabaseHost=database
      - RedisHost=redis

  database:
    image: postgres:15
    networks:
      - backend
    environment:
      - POSTGRES_PASSWORD=password

  redis:
    image: redis:7-alpine
    networks:
      - backend

  nginx:
    image: nginx:alpine
    networks:
      - frontend
    ports:
      - "80:80"
      - "443:443"

networks:
  frontend:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.28.0.0/16
          gateway: 172.28.0.1
  backend:
    driver: bridge
    internal: true  # No external access
    ipam:
      driver: default
      config:
        - subnet: 172.29.0.0/16
```

### 3. **Service Discovery**

```csharp
// Use container names for service discovery
public class DatabaseSettings
{
    public string ConnectionString { get; set; } 
        = "Host=database;Database=mydb;Username=postgres;Password=password";
}

public class RedisSettings
{
    public string Connection { get; set; } = "redis:6379";
}

// In docker-compose, services can reference each other by name
```

### 4. **Network Aliases**

```yaml
version: '3.8'

services:
  api:
    image: myapi:latest
    networks:
      backend:
        aliases:
          - api-service
          - myapi

  database:
    image: postgres:15
    networks:
      backend:
        aliases:
          - db
          - postgres-db

networks:
  backend:
```

---

## Data Management & Volumes

### 1. **Volume Types**

```bash
# Named volumes (managed by Docker)
docker volume create mydata
docker run -v mydata:/app/data myapi:latest

# Bind mounts (host directory)
docker run -v /host/path:/container/path myapi:latest

# tmpfs mounts (in-memory, temporary)
docker run --tmpfs /app/temp:rw,size=100m myapi:latest
```

### 2. **Volume Configuration**

```yaml
# docker-compose.yml
version: '3.8'

services:
  api:
    image: myapi:latest
    volumes:
      # Named volume
      - api-logs:/app/logs
      # Bind mount (development)
      - ./src:/app/src:ro  # read-only
      # tmpfs for temporary files
      - type: tmpfs
        target: /app/temp
        tmpfs:
          size: 100000000  # 100MB

  database:
    image: postgres:15
    volumes:
      # Named volume for persistence
      - db-data:/var/lib/postgresql/data
      # Bind mount for initialization scripts
      - ./init-scripts:/docker-entrypoint-initdb.d:ro

volumes:
  api-logs:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /var/log/myapi
  db-data:
    driver: local
```

### 3. **Backup and Restore**

```bash
# Backup volume
docker run --rm \
  -v mydata:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/mydata-backup.tar.gz -C /data .

# Restore volume
docker run --rm \
  -v mydata:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/mydata-backup.tar.gz -C /data

# Copy files from container
docker cp mycontainer:/app/logs ./logs

# Copy files to container
docker cp ./config.json mycontainer:/app/config.json
```

### 4. **Database Persistence**

```yaml
# docker-compose.yml with proper database setup
version: '3.8'

services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=YourStrong@Passw0rd
      - MSSQL_PID=Developer
    volumes:
      - sqldata:/var/opt/mssql
      - ./backups:/var/opt/mssql/backups
    ports:
      - "1433:1433"
    healthcheck:
      test: /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT 1"
      interval: 10s
      timeout: 3s
      retries: 10
      start_period: 10s

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=mydb
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    ports:
      - "5432:5432"

volumes:
  sqldata:
  pgdata:
```

---

## Debugging & Troubleshooting

### 1. **Debugging in Container**

```bash
# View container logs
docker logs -f myapi

# Tail last 100 lines
docker logs --tail 100 myapi

# Follow logs with timestamp
docker logs -f --timestamps myapi

# Execute bash in running container
docker exec -it myapi /bin/bash

# Run shell in new container from image
docker run -it --rm myapi:latest /bin/bash

# Copy files from container for inspection
docker cp myapi:/app/appsettings.json ./appsettings.json
```

### 2. **VS Code Debugging**

```json
// .vscode/launch.json
// Configuration for debugging .NET applications in Docker containers
{
  "version": "0.2.0",
  "configurations": [
    {
      // Configuration 1: Attach to running container
      "name": "Docker .NET Attach",
      "type": "docker",           // VS Code Docker extension
      "request": "attach",        // Attach to already-running process
      "platform": "netCore",      // .NET Core/5+/6+/7+/8+ platform
      
      // Map container paths to local workspace paths
      // This allows VS Code to show correct source files during debugging
      "sourceFileMap": {
        "/src": "${workspaceFolder}/src"  // Container /src → local workspace/src
      },
      
      // Process name to attach to (dotnet is the .NET runtime process)
      "processName": "dotnet"
    },
    {
      // Configuration 2: Launch container with debugging
      "name": "Docker .NET Launch",
      "type": "docker",
      "request": "launch",        // Start new debugging session
      
      // VS Code task to run before debugging (defined in tasks.json)
      // This task typically builds and starts the container
      "preLaunchTask": "docker-run: debug",
      
      // .NET-specific settings
      "netCore": {
        // Path to the project file to debug
        "appProject": "${workspaceFolder}/src/MyApi/MyApi.csproj"
      }
    }
  ]
}
```

```dockerfile
# =============================================================================
# DEBUG DOCKERFILE - For debugging .NET in Docker with VS Code/Visual Studio
# =============================================================================
# File: Dockerfile.debug
# Purpose: Includes vsdbg (Visual Studio Debugger) for remote debugging
# =============================================================================

# Use SDK image (contains compilation tools)
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# -----------------------------------------------------------------------------
# Install Visual Studio Remote Debugger (vsdbg)
# -----------------------------------------------------------------------------
# RUN: Chain multiple commands with && (creates single layer)
# apt-get update: Refresh package list
# apt-get install -y unzip: Install unzip (needed for vsdbg installation)
# curl: Download vsdbg installer script
#   -sSL: Silent, show errors, follow redirects
#   https://aka.ms/getvsdbgsh: Microsoft's debugger installer script
# /bin/sh /dev/stdin: Execute downloaded script
#   -v latest: Install latest version
#   -l /vsdbg: Install to /vsdbg directory
RUN apt-get update && apt-get install -y unzip && \
    curl -sSL https://aka.ms/getvsdbgsh | \
    /bin/sh /dev/stdin -v latest -l /vsdbg

# Copy source code
COPY . .

# Build in Debug configuration
# Debug build includes:
#   - PDB files (symbol files for debugging)
#   - No optimizations (easier to debug)
#   - Debug symbols
RUN dotnet build -c Debug

# -----------------------------------------------------------------------------
# Expose debugging port
# -----------------------------------------------------------------------------
# EXPOSE 40000: Port used by vsdbg for remote debugging
# VS Code/Visual Studio connects to this port to control debugger
EXPOSE 40000

# -----------------------------------------------------------------------------
# Entry point for debugging
# -----------------------------------------------------------------------------
# dotnet run: Start the application
#   --no-build: Don't rebuild (use existing Debug build)
#   --no-launch-profile: Don't use launchSettings.json profiles
#     (Prevents conflicts with container environment)
ENTRYPOINT ["dotnet", "run", "--no-build", "--no-launch-profile"]
```

### 3. **Health Checks**

```dockerfile
# =============================================================================
# DOCKERFILE WITH HEALTH CHECK - Container health monitoring
# =============================================================================
# Health checks help orchestrators (Docker, Kubernetes) determine if:
#   - Container is running correctly
#   - Container is ready to receive traffic
#   - Container needs to be restarted
# =============================================================================

# Use runtime-only image
FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app

# Copy published application (assumes multi-stage build)
COPY --from=publish /app/publish .

# -----------------------------------------------------------------------------
# Install curl for health check command
# -----------------------------------------------------------------------------
# RUN: Chain commands with && (single layer, more efficient)
# apt-get update: Refresh package repository
# apt-get install -y curl:
#   -y: Automatically answer yes to prompts
#   curl: Command-line HTTP client (for health check requests)
# rm -rf /var/lib/apt/lists/*:
#   Delete package lists after installation
#   Reduces image size by ~20-30MB
#   Security: Removes potentially outdated package metadata
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Configure health check
# -----------------------------------------------------------------------------
# HEALTHCHECK: Instruction tells Docker how to test container health
# Parameters:
#   --interval=30s: Run health check every 30 seconds
#   --timeout=3s: Each health check times out after 3 seconds
#   --start-period=5s: Give the app 5 seconds to start before first check
#     (Prevents false failures during app startup)
#   --retries=3: Mark container unhealthy after 3 consecutive failures
# CMD: The actual health check command to run
#   curl -f http://localhost/health:
#     -f: Fail silently on HTTP errors (returns non-zero exit code)
#     Calls the /health endpoint on the application
#   || exit 1: If curl fails, exit with code 1 (marks as unhealthy)
# Health states:
#   - starting: During start-period
#   - healthy: Health check succeeded
#   - unhealthy: Health check failed retries times
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Start the application
ENTRYPOINT ["dotnet", "MyApi.dll"]
```

```csharp
// HealthCheck implementation in .NET
// Program.cs
builder.Services.AddHealthChecks()
    .AddCheck("self", () => HealthCheckResult.Healthy())
    .AddSqlServer(
        connectionString: builder.Configuration.GetConnectionString("DefaultConnection"),
        name: "database",
        failureStatus: HealthStatus.Degraded)
    .AddRedis(
        redisConnectionString: builder.Configuration.GetConnectionString("Redis"),
        name: "redis",
        failureStatus: HealthStatus.Degraded);

app.MapHealthChecks("/health", new HealthCheckOptions
{
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
                description = e.Value.Description,
                duration = e.Value.Duration
            }),
            totalDuration = report.TotalDuration
        });
        
        await context.Response.WriteAsync(result);
    }
});

app.MapHealthChecks("/health/live", new HealthCheckOptions
{
    Predicate = _ => false
});

app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready")
});
```

### 4. **Inspecting Container**

```bash
# Inspect container details
docker inspect myapi

# Get specific information
docker inspect --format='{{.State.Status}}' myapi
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' myapi
docker inspect --format='{{.Config.Image}}' myapi

# View container stats
docker stats myapi

# View all containers stats
docker stats

# View container processes
docker top myapi

# View port mappings
docker port myapi

# View changes to filesystem
docker diff myapi
```

### 5. **Common Issues**

```bash
# Issue: Container exits immediately
# Solution: Check logs
docker logs myapi

# Issue: Port already in use
# Solution: Check what's using the port
netstat -ano | findstr :5000  # Windows
lsof -i :5000                 # Linux/Mac

# Issue: Cannot connect to container
# Solution: Verify network and firewall
docker network inspect bridge
docker exec myapi netstat -tulpn

# Issue: Out of disk space
# Solution: Clean up Docker resources
docker system prune -a
docker volume prune
docker image prune -a

# Issue: Permission denied
# Solution: Check file ownership
docker exec myapi ls -la /app

# Issue: DNS resolution fails
# Solution: Configure DNS
docker run --dns 8.8.8.8 --dns 8.8.4.4 myapi:latest
```

### 6. **Performance Profiling**

```bash
# Monitor resource usage
docker stats myapi

# Detailed resource usage
docker stats --no-stream myapi

# Container events
docker events --filter container=myapi

# System-wide info
docker system df
docker system df -v
```

```bash
# Use dotnet-trace for profiling
docker exec myapi dotnet-trace collect --process-id 1 --duration 00:00:30

# Use dotnet-counters for metrics
docker exec myapi dotnet-counters monitor --process-id 1

# Use dotnet-dump for memory dump
docker exec myapi dotnet-dump collect --process-id 1
```

---

## Production Deployment Strategies

### 1. **Blue-Green Deployment**

```bash
#!/bin/bash
# blue-green-deploy.sh

# Deploy green version
docker-compose -f docker-compose.prod.yml up -d api-green

# Wait for health check
echo "Waiting for green to be healthy..."
until docker-compose -f docker-compose.prod.yml exec api-green curl -f http://localhost/health; do
  sleep 5
done

# Switch traffic to green
docker-compose -f docker-compose.prod.yml exec nginx \
  nginx -s reload -c /etc/nginx/nginx-green.conf

# Remove blue version
docker-compose -f docker-compose.prod.yml stop api-blue
docker-compose -f docker-compose.prod.yml rm -f api-blue

echo "Deployment complete!"
```

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  api-blue:
    image: myapi:blue
    networks:
      - app-network

  api-green:
    image: myapi:green
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    networks:
      - app-network
    depends_on:
      - api-blue
      - api-green

networks:
  app-network:
```

### 2. **Rolling Updates with Docker Swarm**

```bash
# Initialize Swarm
docker swarm init

# Create service
docker service create \
  --name myapi \
  --replicas 5 \
  --update-delay 10s \
  --update-parallelism 2 \
  --update-failure-action rollback \
  --rollback-parallelism 2 \
  --rollback-delay 5s \
  --publish 8080:80 \
  myapi:v1

# Update service (rolling update)
docker service update --image myapi:v2 myapi

# Scale service
docker service scale myapi=10

# View service status
docker service ps myapi

# Rollback if needed
docker service rollback myapi
```

### 3. **Canary Deployment**

```yaml
# kubernetes-canary.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapi-stable
spec:
  replicas: 9
  selector:
    matchLabels:
      app: myapi
      version: stable
  template:
    metadata:
      labels:
        app: myapi
        version: stable
    spec:
      containers:
      - name: myapi
        image: myapi:v1
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapi-canary
spec:
  replicas: 1  # 10% traffic
  selector:
    matchLabels:
      app: myapi
      version: canary
  template:
    metadata:
      labels:
        app: myapi
        version: canary
    spec:
      containers:
      - name: myapi
        image: myapi:v2
---
apiVersion: v1
kind: Service
metadata:
  name: myapi
spec:
  selector:
    app: myapi  # Matches both stable and canary
  ports:
  - port: 80
    targetPort: 80
```

### 4. **Production-Ready docker-compose**

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  api:
    image: ${REGISTRY}/myapi:${VERSION}
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
        order: start-first
      rollback_config:
        parallelism: 1
        delay: 5s
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ASPNETCORE_URLS=http://+:80
    secrets:
      - db_connection
      - api_key
    networks:
      - app-network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 40s

secrets:
  db_connection:
    external: true
  api_key:
    external: true

networks:
  app-network:
    external: true
```

### 5. **Zero-Downtime Deployment**

```bash
#!/bin/bash
# zero-downtime-deploy.sh

set -e

NEW_VERSION=$1
OLD_VERSION=$(docker ps --filter "name=myapi" --format "{{.Image}}" | head -1)

echo "Current version: $OLD_VERSION"
echo "Deploying version: $NEW_VERSION"

# Pull new image
docker pull myregistry.azurecr.io/myapi:$NEW_VERSION

# Start new containers
docker-compose -f docker-compose.prod.yml up -d --scale api=6 --no-recreate

# Wait for new containers to be healthy
echo "Waiting for new containers..."
sleep 30

# Check health
for i in {1..10}; do
  if curl -f http://localhost/health; then
    echo "Health check passed"
    break
  fi
  sleep 5
done

# Gradually shift traffic
docker-compose -f docker-compose.prod.yml up -d --scale api=5 --no-recreate
sleep 10
docker-compose -f docker-compose.prod.yml up -d --scale api=4 --no-recreate
sleep 10
docker-compose -f docker-compose.prod.yml up -d --scale api=3 --no-recreate

# Remove old containers
docker ps --filter "ancestor=$OLD_VERSION" -q | xargs -r docker stop
docker ps -a --filter "ancestor=$OLD_VERSION" -q | xargs -r docker rm

echo "Deployment complete!"
```

---

## Real-World Scenarios

### 1. **Microservices E-Commerce Platform**

```yaml
# Full e-commerce stack
version: '3.8'

services:
  # Frontend
  web:
    build: ./src/Web
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - api-gateway

  # API Gateway
  api-gateway:
    build: ./src/ApiGateway
    environment:
      - Services__Auth=http://auth-api
      - Services__Catalog=http://catalog-api
      - Services__Orders=http://orders-api
      - Services__Customers=http://customers-api
    depends_on:
      - auth-api
      - catalog-api
      - orders-api
      - customers-api

  # Microservices
  auth-api:
    build: ./src/Services/Auth
    environment:
      - ConnectionStrings__AuthDb=Server=auth-db;Database=AuthDb
      - Redis__Connection=redis:6379
    depends_on:
      - auth-db
      - redis

  catalog-api:
    build: ./src/Services/Catalog
    environment:
      - ConnectionStrings__CatalogDb=Server=catalog-db;Database=CatalogDb
      - Elasticsearch__Url=http://elasticsearch:9200
    depends_on:
      - catalog-db
      - elasticsearch

  orders-api:
    build: ./src/Services/Orders
    environment:
      - ConnectionStrings__OrdersDb=Server=orders-db;Database=OrdersDb
      - RabbitMQ__Host=rabbitmq
      - EventBus__Connection=rabbitmq
    depends_on:
      - orders-db
      - rabbitmq

  customers-api:
    build: ./src/Services/Customers
    environment:
      - ConnectionStrings__CustomersDb=Server=customers-db;Database=CustomersDb
    depends_on:
      - customers-db

  # Background Workers
  order-processor:
    build:
      context: ./src/Workers/OrderProcessor
    environment:
      - RabbitMQ__Host=rabbitmq
      - ConnectionStrings__OrdersDb=Server=orders-db;Database=OrdersDb
    depends_on:
      - rabbitmq
      - orders-db

  email-sender:
    build:
      context: ./src/Workers/EmailSender
    environment:
      - RabbitMQ__Host=rabbitmq
      - SendGrid__ApiKey=${SENDGRID_API_KEY}
    depends_on:
      - rabbitmq

  # Databases
  auth-db:
    image: postgres:15-alpine
    volumes:
      - auth-data:/var/lib/postgresql/data

  catalog-db:
    image: postgres:15-alpine
    volumes:
      - catalog-data:/var/lib/postgresql/data

  orders-db:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=${SQL_PASSWORD}
    volumes:
      - orders-data:/var/opt/mssql

  customers-db:
    image: postgres:15-alpine
    volumes:
      - customers-data:/var/lib/postgresql/data

  # Infrastructure
  redis:
    image: redis:7-alpine
    volumes:
      - redis-data:/data

  rabbitmq:
    image: rabbitmq:3-management-alpine
    ports:
      - "15672:15672"
    volumes:
      - rabbitmq-data:/var/lib/rabbitmq

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    volumes:
      - es-data:/usr/share/elasticsearch/data

  # Monitoring
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    volumes:
      - grafana-data:/var/lib/grafana
    ports:
      - "3000:3000"

volumes:
  auth-data:
  catalog-data:
  orders-data:
  customers-data:
  redis-data:
  rabbitmq-data:
  es-data:
  prometheus-data:
  grafana-data:
```

### 2. **Clean Architecture Solution**

```dockerfile
# Multi-project solution Dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and all project files
COPY ["MyApp.sln", "./"]
COPY ["src/MyApp.Api/MyApp.Api.csproj", "src/MyApp.Api/"]
COPY ["src/MyApp.Application/MyApp.Application.csproj", "src/MyApp.Application/"]
COPY ["src/MyApp.Domain/MyApp.Domain.csproj", "src/MyApp.Domain/"]
COPY ["src/MyApp.Infrastructure/MyApp.Infrastructure.csproj", "src/MyApp.Infrastructure/"]
COPY ["tests/MyApp.UnitTests/MyApp.UnitTests.csproj", "tests/MyApp.UnitTests/"]
COPY ["tests/MyApp.IntegrationTests/MyApp.IntegrationTests.csproj", "tests/MyApp.IntegrationTests/"]

# Restore with specific runtime
RUN dotnet restore "src/MyApp.Api/MyApp.Api.csproj" -r linux-x64

# Copy source code
COPY . .

# Build
WORKDIR "/src/src/MyApp.Api"
RUN dotnet build "MyApp.Api.csproj" -c Release -o /app/build --no-restore

# Run tests
FROM build AS test
WORKDIR /src
RUN dotnet test "tests/MyApp.UnitTests/MyApp.UnitTests.csproj" \
    --no-restore \
    --logger "trx;LogFileName=unit-test-results.trx"
RUN dotnet test "tests/MyApp.IntegrationTests/MyApp.IntegrationTests.csproj" \
    --no-restore \
    --logger "trx;LogFileName=integration-test-results.trx"

# Publish
FROM build AS publish
WORKDIR "/src/src/MyApp.Api"
RUN dotnet publish "MyApp.Api.csproj" \
    -c Release \
    -o /app/publish \
    -r linux-x64 \
    --self-contained false \
    --no-restore \
    /p:PublishReadyToRun=true

# Final runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Create non-root user
RUN groupadd -r appuser --gid=1000 && \
    useradd -r -g appuser --uid=1000 --create-home appuser

COPY --from=publish --chown=appuser:appuser /app/publish .

USER appuser

EXPOSE 8080
EXPOSE 8081

ENV ASPNETCORE_URLS=http://+:8080 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "MyApp.Api.dll"]
```

### 3. **Background Worker Service**

```csharp
// Worker.cs
public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;
    private readonly IServiceProvider _serviceProvider;

    public Worker(ILogger<Worker> logger, IServiceProvider serviceProvider)
    {
        _logger = logger;
        _serviceProvider = serviceProvider;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Worker starting at: {time}", DateTimeOffset.Now);

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _serviceProvider.CreateScope();
                var processor = scope.ServiceProvider.GetRequiredService<IMessageProcessor>();
                
                await processor.ProcessMessagesAsync(stoppingToken);
                
                await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred executing worker");
                await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
            }
        }

        _logger.LogInformation("Worker stopping at: {time}", DateTimeOffset.Now);
    }
}
```

```dockerfile
# =============================================================================
# WORKER SERVICE DOCKERFILE - Background processing application
# =============================================================================
# Worker Service characteristics:
#   - No HTTP endpoints (doesn't need Kestrel)
#   - Runs background tasks
#   - Processes queues, scheduled jobs, etc.
#   - Uses Microsoft.Extensions.Hosting (not ASP.NET Core)
# =============================================================================

# -----------------------------------------------------------------------------
# Build stage
# -----------------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

# Copy and restore project
# Worker services typically have fewer dependencies than web APIs
COPY ["MyApp.Worker/MyApp.Worker.csproj", "MyApp.Worker/"]
RUN dotnet restore "MyApp.Worker/MyApp.Worker.csproj"

# Copy source and publish
COPY . .
WORKDIR "/src/MyApp.Worker"

# Publish worker service
# Note: Worker services are typically smaller than web APIs
RUN dotnet publish -c Release -o /app/publish

# -----------------------------------------------------------------------------
# Final runtime image
# -----------------------------------------------------------------------------
# IMPORTANT: Use 'runtime' image, NOT 'aspnet'
# Why?
#   - aspnet image includes Kestrel web server (~200MB)
#   - runtime image is base .NET runtime only (~190MB)
#   - Worker services don't need Kestrel (no HTTP)
#   - Saves ~10MB and reduces attack surface
FROM mcr.microsoft.com/dotnet/runtime:8.0 AS final

WORKDIR /app

# Copy published worker
COPY --from=publish /app/publish .

# -----------------------------------------------------------------------------
# Entry point for worker service
# -----------------------------------------------------------------------------
# WorkerService runs continuously processing background tasks:
#   - Message queue consumers
#   - Scheduled jobs
#   - Data synchronization
#   - Cleanup tasks
ENTRYPOINT ["dotnet", "MyApp.Worker.dll"]
```

```yaml
# docker-compose.yml for worker
version: '3.8'

services:
  worker:
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      - DOTNET_ENVIRONMENT=Production
      - RabbitMQ_Host=rabbitmq
      - ConnectionStrings__DefaultConnection=Server=db;Database=WorkerDb
    depends_on:
      - rabbitmq
      - db
    restart: unless-stopped
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M

  rabbitmq:
    image: rabbitmq:3-management-alpine
    ports:
      - "5672:5672"
      - "15672:15672"

  db:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=YourStrong@Passw0rd
```

---

## Common Pitfalls & Solutions

### 1. **Image Size Issues**

**Problem**: Images are too large (>1GB)

**Solutions**:
```dockerfile
# Use multi-stage builds
# Use Alpine or distroless base images
# Clean up in same RUN command

# BAD
FROM mcr.microsoft.com/dotnet/sdk:8.0
COPY . .
RUN dotnet publish -c Release

# GOOD
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
COPY . .
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine
COPY --from=build /app .

# Remove unnecessary files
RUN find . -name "*.pdb" -delete && \
    find . -name "*.xml" -delete
```

### 2. **Slow Builds**

**Problem**: Docker builds take too long

**Solutions**:
```dockerfile
# Order layers from least to most frequently changing
# Copy only what's needed for each step
# Use .dockerignore

# .dockerignore
bin/
obj/
.vs/
.git/
*.md
.dockerignore
Dockerfile*
```

### 3. **Connection String Issues**

**Problem**: Cannot connect from container to host database

**Solutions**:
```bash
# Use host.docker.internal (Windows/Mac)
Server=host.docker.internal;Database=MyDb;User=sa;Password=password

# Use Docker network and service names
Server=sqlserver;Database=MyDb;User=sa;Password=password

# Linux: use host IP
Server=172.17.0.1;Database=MyDb;User=sa;Password=password
```

### 4. **Environment-Specific Configuration**

**Problem**: Different configurations for dev/staging/prod

**Solutions**:
```csharp
// Use layered configuration
var builder = WebApplication.CreateBuilder(args);

// Base configuration
builder.Configuration
    .AddJsonFile("appsettings.json", optional: false)
    .AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.json", optional: true)
    .AddEnvironmentVariables()
    .AddUserSecrets<Program>(optional: true);

// Override with Docker/K8s secrets
if (builder.Environment.IsProduction())
{
    builder.Configuration.AddKeyVault(/* ... */);
}
```

```yaml
# docker-compose with env files
version: '3.8'

services:
  api:
    image: myapi:latest
    env_file:
      - .env.common
      - .env.${ENVIRONMENT}
    environment:
      - ASPNETCORE_ENVIRONMENT=${ENVIRONMENT}
```

### 5. **Port Conflicts**

**Problem**: Port already in use

**Solutions**:
```bash
# Use different port mappings
docker run -p 8080:80 myapi:latest  # Map container 80 to host 8080

# Let Docker assign random port
docker run -P myapi:latest

# Check what's using a port
netstat -ano | findstr :5000  # Windows
lsof -i :5000                 # Linux/Mac

# Kill process using port (Linux/Mac)
kill -9 $(lsof -t -i:5000)
```

### 6. **Memory Leaks**

**Problem**: Container memory grows indefinitely

**Solutions**:
```csharp
// Proper disposal of resources
public class MyService : IDisposable
{
    private readonly HttpClient _httpClient;
    
    public MyService(IHttpClientFactory httpClientFactory)
    {
        _httpClient = httpClientFactory.CreateClient();
    }
    
    public void Dispose()
    {
        _httpClient?.Dispose();
    }
}

// Use memory limits
// docker-compose.yml
services:
  api:
    deploy:
      resources:
        limits:
          memory: 512M
```

### 7. **Logging Issues**

**Problem**: Cannot see application logs

**Solutions**:
```csharp
// Configure console logging
var builder = WebApplication.CreateBuilder(args);

builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();

// Write to stdout/stderr
Console.WriteLine("Application starting...");
```

```bash
# View logs
docker logs -f myapi

# Configure Docker logging driver
docker run --log-driver json-file --log-opt max-size=10m --log-opt max-file=3 myapi:latest
```

---

## Additional Resources

### Official Documentation
- [Docker Documentation](https://docs.docker.com/)
- [.NET Docker Images](https://hub.docker.com/_/microsoft-dotnet)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

### Best Practices
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [.NET Microservices Architecture](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/)
- [12-Factor App](https://12factor.net/)

### Tools
- **Docker Desktop**: Local development environment
- **Visual Studio Code**: Docker extension for VS Code
- **Portainer**: Web-based Docker management UI
- **Kubernetes Dashboard**: Web-based Kubernetes UI
- **Helm**: Kubernetes package manager
- **Skaffold**: CI/CD for Kubernetes applications

### Useful Commands Reference

```bash
# Container Management
docker run                    # Create and start container
docker start/stop/restart     # Control container state
docker ps                     # List containers
docker rm                     # Remove container
docker exec                   # Execute command in container
docker logs                   # View container logs
docker inspect                # View container details

# Image Management
docker build                  # Build image from Dockerfile
docker pull/push              # Download/upload image
docker images                 # List images
docker rmi                    # Remove image
docker tag                    # Tag image
docker history                # View image layers

# System Management
docker system df              # Show disk usage
docker system prune           # Remove unused data
docker volume prune           # Remove unused volumes
docker network prune          # Remove unused networks

# Docker Compose
docker-compose up             # Create and start services
docker-compose down           # Stop and remove services
docker-compose ps             # List services
docker-compose logs           # View service logs
docker-compose build          # Build service images
docker-compose exec           # Execute command in service

# Kubernetes
kubectl get                   # List resources
kubectl describe              # Show resource details
kubectl apply                 # Apply configuration
kubectl delete                # Delete resources
kubectl logs                  # View pod logs
kubectl exec                  # Execute command in pod
kubectl port-forward          # Forward ports
kubectl scale                 # Scale deployment
```

---

## Conclusion

This guide covers the essential aspects of using Docker with .NET applications:

1. **Fundamentals**: Understanding Docker concepts and commands
2. **Best Practices**: Writing optimized, secure Dockerfiles
3. **Development**: Setting up efficient development workflows
4. **Production**: Deploying and managing containerized applications
5. **Troubleshooting**: Identifying and resolving common issues

**Key Takeaways**:
- Always use multi-stage builds for .NET applications
- Run containers as non-root users for security
- Implement health checks for production deployments
- Use docker-compose for local development
- Consider Kubernetes for production orchestration
- Monitor and log containerized applications
- Practice proper secret management
- Keep images small and security-scanned

**Next Steps**:
1. Practice with the examples in this guide
2. Set up a sample microservices project
3. Implement CI/CD pipelines
4. Learn Kubernetes for production deployments
5. Explore service mesh technologies (Istio, Linkerd)
6. Study advanced monitoring and observability

Remember: Containerization is a journey. Start small, iterate, and continuously improve your Docker skills!

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Author**: Docker for .NET Developers Guide  
**License**: Free to use and distribute


# Docker & Docker Compose Commands — Mind Map

## Legend
```
  ★  = Very commonly used flag / option
  -x  = Short flag
  --long  = Long flag (same option)
  ▸  = Allowed values / enum
  →  = What it does / result
```
---

```
DOCKER COMMANDS
│
├──────────────────────────────────────────────────────────────
│  IMAGE MANAGEMENT
├──────────────────────────────────────────────────────────────
│
│  ┌─── docker pull  <image[:tag]>
│  │    ★ -a  / --all-tags             pull every tag of the image
│  │       --platform linux/amd64      pull for specific OS/arch
│  │       --quiet / -q                suppress verbose output
│  │       --disable-content-trust     skip image verification
│  │
│  ├─── docker build  <context>
│  │    ★ -t  / --tag       name:tag          tag the built image
│  │    ★ -f  / --file      Dockerfile.prod   alternate Dockerfile path
│  │    ★ --no-cache                          ignore layer cache
│  │    ★ --build-arg  KEY=VALUE              pass ARG to Dockerfile
│  │    ★ --target     stage-name             stop at named build stage
│  │       --platform  linux/amd64|arm64      cross-platform build
│  │       --pull                             always pull fresh base image
│  │       --progress  ▸ plain|tty|auto       output format
│  │       --secret    id=mysecret,src=file   mount secret (no layer leak)
│  │       --ssh       default=$SSH_AUTH_SOCK forward SSH agent
│  │       --label     key=value              add image metadata label
│  │       -q  / --quiet                      suppress build output
│  │       --iidfile   path                   write image ID to file
│  │       --cache-from image                 external cache source
│  │       --output    type=local,dest=./out  export build output
│  │
│  ├─── docker push  <name[:tag]>
│  │    ★ --all-tags / -a              push all tags for image
│  │       --quiet / -q                suppress output
│  │       --disable-content-trust
│  │
│  ├─── docker images  /  docker image ls
│  │    ★ -a  / --all                  show intermediate layers too
│  │    ★ -q  / --quiet                image IDs only
│  │    ★ -f  / --filter               filter output
│  │           dangling=true           → untagged images
│  │           label=key=value
│  │           before=image / since=image
│  │           reference=name:tag
│  │       --format  "{{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.Size}}"
│  │       --no-trunc                  show full image ID
│  │       --digests                   show SHA256 digest
│  │
│  ├─── docker rmi  /  docker image rm  <image [image…]>
│  │    ★ -f  / --force                force remove (even if tagged)
│  │       --no-prune                  keep untagged parent images
│  │
│  ├─── docker tag  <SOURCE>  <TARGET>
│  │       (no flags; just: docker tag ubuntu:22.04 myrepo/ubuntu:latest)
│  │
│  ├─── docker history  <image>
│  │       --no-trunc                  show full commands
│  │       -q  / --quiet               layer IDs only
│  │       --format "{{.CreatedBy}}"
│  │       -H  / --human               human-readable sizes (default)
│  │
│  ├─── docker inspect  <name|id>
│  │    ★ -f  / --format  '{{.NetworkSettings.IPAddress}}'
│  │       -s  / --size                show filesystem size
│  │       --type  ▸ container|image|network|volume|node|task
│  │
│  ├─── docker save  <image [image…]>
│  │    ★ -o  / --output  archive.tar  write to file (not stdout)
│  │
│  ├─── docker load
│  │    ★ -i  / --input   archive.tar  read from file (not stdin)
│  │       -q  / --quiet
│  │
│  ├─── docker image prune
│  │    ★ -a  / --all                  remove ALL unused images
│  │    ★ -f  / --force                no prompt
│  │       --filter  until=24h
│  │
│  └─── docker image inspect  (alias for docker inspect --type image)
│
├──────────────────────────────────────────────────────────────
│  CONTAINER LIFECYCLE
├──────────────────────────────────────────────────────────────
│
│  ┌─── docker run  <image>  [command]          ← CREATE + START
│  │    │
│  │    ├── Identity & Naming
│  │    │  ★ --name      container-name         assign a name
│  │    │     --hostname  custom-hostname        override container hostname
│  │    │     --label  key=value                metadata label
│  │    │
│  │    ├── Mode
│  │    │  ★ -d  / --detach                     run in background
│  │    │  ★ -it                                interactive + pseudo-TTY
│  │    │  ★ --rm                               auto-remove on exit
│  │    │     --init                            use tini as PID 1 (signal handling)
│  │    │     --sig-proxy   (default true)      proxy signals to process
│  │    │     --detach-keys "ctrl-p,ctrl-q"     custom detach sequence
│  │    │
│  │    ├── Ports
│  │    │  ★ -p  / --publish  host:container[:udp]    expose port
│  │    │                     127.0.0.1:8080:80        bind to loopback only
│  │    │  ★ -P  / --publish-all                      publish all EXPOSE'd ports
│  │    │
│  │    ├── Environment
│  │    │  ★ -e  / --env       KEY=VALUE               set env var
│  │    │  ★ --env-file        .env                    load env file
│  │    │
│  │    ├── Volumes & Mounts
│  │    │  ★ -v  / --volume    host:container[:ro,z]   bind mount or named volume
│  │    │  ★ --mount           type=bind,source=,target=,readonly
│  │    │                      type=volume,source=vol,target=
│  │    │                      type=tmpfs,target=/tmp,tmpfs-size=100m
│  │    │     --volumes-from   container-name          mount all volumes from container
│  │    │     --read-only                              make root filesystem read-only
│  │    │     --tmpfs          /tmp:size=100m          in-memory mount
│  │    │
│  │    ├── Network
│  │    │  ★ --network         network-name            connect to network
│  │    │                      ▸ bridge|host|none|container:name
│  │    │     --network-alias  alias                   DNS alias in network
│  │    │     --dns            8.8.8.8                 custom DNS server
│  │    │     --add-host       hostname:ip             extra /etc/hosts entry
│  │    │     --link           container:alias         legacy; prefer networks
│  │    │     --ip             172.20.0.5              static IP in network
│  │    │
│  │    ├── Resource Limits
│  │    │  ★ -m  / --memory    512m|2g                 max memory
│  │    │  ★ --cpus            0.5                     fractional CPUs
│  │    │     --memory-swap    1g                      memory+swap (= no swap if = memory)
│  │    │     --memory-reservation  256m               soft limit
│  │    │     --cpu-shares     512                     relative CPU weight
│  │    │     --cpu-period / --cpu-quota               precise CPU throttle
│  │    │     --pids-limit     100                     max processes
│  │    │     --blkio-weight   500                     I/O weight (10-1000)
│  │    │     --device         /dev/snd:/dev/snd       expose host device
│  │    │     --gpus           all|device=0            GPU access
│  │    │     --shm-size       64m                     /dev/shm size
│  │    │
│  │    ├── Restart Policy
│  │    │  ★ --restart         ▸ no | always | on-failure[:N] | unless-stopped
│  │    │
│  │    ├── User & Working Dir
│  │    │  ★ -w  / --workdir   /app                    working directory
│  │    │  ★ -u  / --user      uid | uid:gid | user    run as user
│  │    │
│  │    ├── Entrypoint & Command
│  │    │     --entrypoint     /bin/sh                 override ENTRYPOINT
│  │    │     (everything after image = override CMD)
│  │    │
│  │    ├── Security
│  │    │     --privileged                             full host capabilities (DANGER)
│  │    │     --cap-add        SYS_PTRACE              add Linux capability
│  │    │     --cap-drop       ALL                     drop capability
│  │    │     --security-opt   no-new-privileges:true
│  │    │     --security-opt   seccomp=profile.json
│  │    │     --security-opt   apparmor=profile
│  │    │     --read-only                              immutable root fs
│  │    │
│  │    ├── Logging
│  │    │     --log-driver     ▸ json-file|syslog|journald|fluentd|none|awslogs
│  │    │     --log-opt        max-size=10m,max-file=3
│  │    │
│  │    ├── Health Check
│  │    │     --health-cmd     "curl -f http://localhost/ || exit 1"
│  │    │     --health-interval       30s
│  │    │     --health-timeout        10s
│  │    │     --health-retries        3
│  │    │     --health-start-period   15s
│  │    │     --no-healthcheck        disable
│  │    │
│  │    └── IPC / PID / Namespace
│  │          --ipc            ▸ host | shareable | container:<name>
│  │          --pid            ▸ host                  share host PID namespace
│  │          --userns         ▸ host                  share host user namespace
│  │
│  ├─── docker create  <image>  [command]      ← like run but doesn't start
│  │       (all docker run flags apply; returns container ID)
│  │
│  ├─── docker start  <container [container…]>
│  │       -a  / --attach                      attach stdout/stderr
│  │       -i  / --interactive                 attach stdin
│  │
│  ├─── docker stop   <container [container…]>
│  │    ★ -t  / --time  10                     seconds to wait before SIGKILL
│  │
│  ├─── docker restart  <container [container…]>
│  │       -t  / --time  10
│  │
│  ├─── docker kill   <container [container…]>
│  │       -s  / --signal  ▸ SIGTERM|SIGKILL|SIGHUP|SIGUSR1|...
│  │
│  ├─── docker pause   / docker unpause  <container [container…]>
│  │       (SIGSTOP / SIGCONT via cgroups freezer)
│  │
│  ├─── docker rm  <container [container…]>
│  │    ★ -f  / --force                        stop then remove
│  │    ★ -v  / --volumes                      remove anonymous volumes too
│  │       --link                              remove link
│  │
│  └─── docker commit  <container>  [repository[:tag]]
│           -a  / --author   "name <email>"
│           -m  / --message  "commit message"
│           -c  / --change   "ENV KEY=val"     apply Dockerfile instruction
│           -p  / --pause    (default true)    pause container during commit
│
├──────────────────────────────────────────────────────────────
│  CONTAINER INTERACTION & OBSERVATION
├──────────────────────────────────────────────────────────────
│
│  ┌─── docker ps  /  docker container ls
│  │    ★ -a  / --all                          show stopped containers too
│  │    ★ -q  / --quiet                        container IDs only
│  │    ★ -f  / --filter                       filter containers
│  │           status=▸ running|paused|exited|created|restarting|dead
│  │           name=mycontainer
│  │           ancestor=image[:tag]
│  │           label=key=value
│  │           network=name|id
│  │           volume=name|mountpoint
│  │           publish=port[/proto]
│  │    ★ --format  "{{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
│  │       -n  / --last  N                     show last N containers
│  │       -l  / --latest                      show last container
│  │       -s  / --size                        show disk usage
│  │       --no-trunc
│  │
│  ├─── docker exec  <container>  <command>
│  │    ★ -it                                  interactive + TTY (e.g. /bin/bash)
│  │    ★ -d  / --detach                       run in background
│  │    ★ -e  / --env  KEY=VALUE               set env for exec session
│  │       -u  / --user                        run as user
│  │       -w  / --workdir                     set working dir
│  │       --privileged                        grant extra privileges
│  │       --env-file                          load env file
│  │       --detach-keys  "ctrl-p,ctrl-q"
│  │
│  ├─── docker logs  <container>
│  │    ★ -f  / --follow                       stream log output
│  │    ★ --tail   50                          last N lines
│  │    ★ --since  "10m" | "2024-01-01"        logs since time/duration
│  │       --until  "2024-01-02"
│  │       -t  / --timestamps                  prepend timestamps
│  │       --details                           show extra attrs (--log-opt)
│  │
│  ├─── docker attach  <container>
│  │       --no-stdin                          do not attach stdin
│  │       --sig-proxy  (default true)         ctrl-c → SIGINT to process
│  │       --detach-keys  "ctrl-p,ctrl-q"
│  │
│  ├─── docker cp  <src>  <dst>
│  │    ★ container:path  host-path            copy FROM container
│  │    ★ host-path       container:path       copy TO container
│  │       -a  / --archive                     preserve ownership+timestamps
│  │       -q  / --quiet                       suppress progress
│  │       -L  / --follow-link                 follow symlinks in src
│  │
│  ├─── docker stats  [container…]
│  │       -a  / --all                         show stopped containers too
│  │       --no-stream                         single snapshot (not live)
│  │       --no-trunc                          full container ID
│  │       --format "{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
│  │
│  ├─── docker top  <container>  [ps options]
│  │       (shows processes running in container; ps aux flags apply)
│  │
│  └─── docker wait  <container>
│           (blocks until container stops; prints exit code)
│
├──────────────────────────────────────────────────────────────
│  NETWORKING
├──────────────────────────────────────────────────────────────
│
│  ┌─── docker network create  <name>
│  │    ★ -d  / --driver  ▸ bridge|overlay|host|none|macvlan|ipvlan
│  │       --subnet       172.18.0.0/16
│  │       --gateway      172.18.0.1
│  │       --ip-range     172.18.5.0/24        sub-range for dynamic IPs
│  │       --attachable                        allow standalone containers (overlay)
│  │       --internal                          no external access
│  │       --ipv6                              enable IPv6
│  │       --label        key=value
│  │       -o  / --opt    com.docker.network.bridge.name=docker1
│  │
│  ├─── docker network ls
│  │       -f  / --filter  driver=bridge | name=mynet | label=key
│  │       -q  / --quiet                       IDs only
│  │       --format
│  │       --no-trunc
│  │
│  ├─── docker network rm  <network [network…]>
│  │       (no flags; fails if containers still connected)
│  │
│  ├─── docker network inspect  <network>
│  │       -f  / --format  '{{range .Containers}}{{.Name}} {{end}}'
│  │       -v  / --verbose
│  │
│  ├─── docker network connect  <network>  <container>
│  │       --alias        alias                DNS alias in this network
│  │       --ip           172.20.0.5           static IPv4
│  │       --ip6          2001:db8::5          static IPv6
│  │       --link-local-ip
│  │
│  ├─── docker network disconnect  <network>  <container>
│  │       -f  / --force
│  │
│  └─── docker network prune
│           -f  / --force
│           --filter  until=24h
│
├──────────────────────────────────────────────────────────────
│  VOLUMES
├──────────────────────────────────────────────────────────────
│
│  ┌─── docker volume create  [name]
│  │       -d  / --driver  ▸ local|nfs|vieux/sshfs|etc
│  │       -o  / --opt     type=nfs,o=addr=server,device=:/path  (driver opts)
│  │       --label         key=value
│  │
│  ├─── docker volume ls
│  │       -f  / --filter  dangling=true|name=vol|driver=local|label=key
│  │       -q  / --quiet
│  │       --format
│  │
│  ├─── docker volume rm  <volume [volume…]>
│  │       -f  / --force   (no error if not found)
│  │
│  ├─── docker volume inspect  <volume>
│  │       -f  / --format  '{{.Mountpoint}}'
│  │
│  └─── docker volume prune
│        ★ -f  / --force
│        ★ -a  / --all                         remove ALL unused (not just anonymous)
│           --filter  label=key=value
│
├──────────────────────────────────────────────────────────────
│  REGISTRY
├──────────────────────────────────────────────────────────────
│
│  ┌─── docker login  [server]
│  │    ★ -u  / --username   user
│  │    ★ --password-stdin               safer: echo $PASS | docker login -u user --password-stdin
│  │       -p  / --password  pass        (avoid; exposes in shell history)
│  │
│  ├─── docker logout  [server]
│  │
│  └─── docker search  <term>
│           -f  / --filter  stars=10 | is-official=true | is-automated=true
│           --limit         N (default 25, max 100)
│           --no-trunc
│           --format
│
├──────────────────────────────────────────────────────────────
│  SYSTEM
├──────────────────────────────────────────────────────────────
│
│  ┌─── docker info
│  │       -f  / --format  '{{.ServerVersion}}'
│  │
│  ├─── docker version
│  │       -f  / --format
│  │
│  ├─── docker system prune
│  │    ★ -a  / --all                    remove ALL unused images (not just dangling)
│  │    ★ -f  / --force                  no confirmation prompt
│  │    ★ --volumes                      also prune volumes
│  │       --filter  until=24h | label=key
│  │
│  ├─── docker system df
│  │       -v  / --verbose               per-item breakdown
│  │       --format
│  │
│  ├─── docker events
│  │       -f  / --filter  event=start|stop|die|pull|push|tag|kill|oom
│  │       -f              type=▸ container|image|network|volume|plugin|daemon
│  │       --since  "1h" | "2024-01-01"
│  │       --until  "2024-01-02"
│  │       --format  '{{.Status}} {{.Actor.Attributes.name}}'
│  │
│  └─── docker context  (manage multiple Docker endpoints)
│           create   name  --docker  host=tcp://remote:2376
│           use      name
│           ls
│           rm       name
│           inspect  name
│
└──────────────────────────────────────────────────────────────


═══════════════════════════════════════════════════════════════
 DOCKER COMPOSE COMMANDS   (docker compose <cmd>)
═══════════════════════════════════════════════════════════════
│
│  ╔═══════════════════════════════════════════════════════╗
│  ║  Global flags (work with ALL compose commands)       ║
│  ║  ★ -f / --file     compose.yml   alternate file      ║
│  ║  ★ -p / --project-name  myapp   override project     ║
│  ║     --env-file    .env           alternate env file   ║
│  ║     --profile     prod           activate profile     ║
│  ║     --ansi        auto|never|always                   ║
│  ║     --compatibility             v2 compat mode        ║
│  ║     --project-directory path    override working dir  ║
│  ╚═══════════════════════════════════════════════════════╝
│
├──────────────────────────────────────────────────────────────
│  LIFECYCLE
├──────────────────────────────────────────────────────────────
│
│  ┌─── docker compose up  [service…]
│  │    ★ -d  / --detach                      run in background
│  │    ★ --build                             always rebuild images first
│  │    ★ --force-recreate                    recreate containers even if config unchanged
│  │    ★ --remove-orphans                    remove containers for removed services
│  │    ★ --scale  service=N                  override scale for a service
│  │       --no-build                         don't build; use existing images
│  │       --no-recreate                      don't recreate existing containers
│  │       --no-deps                          don't start linked services
│  │       --no-start                         create but don't start containers
│  │       --always-recreate-deps             recreate dependent services too
│  │       --renew-anon-volumes   -V          recreate anonymous volumes
│  │       --wait                             wait until services are healthy
│  │       --wait-timeout  30                 seconds to wait for healthy
│  │       --quiet-pull                       suppress pull output
│  │       --dry-run                          show what would happen
│  │       --pull  ▸ always|missing|never     image pull policy
│  │       --timestamps                       show timestamps in output
│  │       --abort-on-container-exit          stop all if any container stops
│  │       --exit-code-from  service          propagate exit code from service
│  │
│  ├─── docker compose down  [service…]
│  │    ★ -v  / --volumes                     remove named volumes declared in compose
│  │    ★ --remove-orphans                    remove containers for removed services
│  │       --rmi  ▸ local|all                 remove images (local=only built locally)
│  │       -t  / --timeout  10                stop timeout seconds
│  │       --dry-run
│  │
│  ├─── docker compose start   [service…]
│  ├─── docker compose stop    [service…]
│  │       -t  / --timeout  10
│  ├─── docker compose restart [service…]
│  │       -t  / --timeout  10
│  ├─── docker compose pause   [service…]
│  └─── docker compose unpause [service…]
│
├──────────────────────────────────────────────────────────────
│  BUILD & IMAGES
├──────────────────────────────────────────────────────────────
│
│  ┌─── docker compose build  [service…]
│  │    ★ --no-cache                          ignore layer cache
│  │    ★ --pull                              always pull latest base image
│  │       --push                             push after build
│  │       --progress  ▸ plain|tty|auto
│  │       --build-arg  KEY=VALUE
│  │       -q  / --quiet
│  │       --ssh  default
│  │       --memory  512m                     memory limit during build
│  │
│  ├─── docker compose pull  [service…]
│  │       --ignore-pull-failures             continue even if pull fails
│  │       --include-deps                     also pull dependencies
│  │       -q  / --quiet
│  │       --policy  ▸ always|missing
│  │
│  ├─── docker compose push  [service…]
│  │       --ignore-push-failures
│  │       -q  / --quiet
│  │       --include-deps
│  │
│  └─── docker compose images  [service…]
│           -q  / --quiet                     IDs only
│           --format  ▸ table|json
│
├──────────────────────────────────────────────────────────────
│  OBSERVE & INSPECT
├──────────────────────────────────────────────────────────────
│
│  ┌─── docker compose ps  [service…]
│  │    ★ -a  / --all                         show stopped containers
│  │    ★ -q  / --quiet                       IDs only
│  │       --services                         list service names only
│  │       --filter  status=▸ running|paused|exited|restarting
│  │       --format  ▸ table|json
│  │       --no-trunc
│  │
│  ├─── docker compose logs  [service…]
│  │    ★ -f  / --follow                      stream output
│  │    ★ --tail  N                           last N lines per service
│  │    ★ --since  "1h" | timestamp
│  │       --until  timestamp
│  │       -t  / --timestamps
│  │       --no-color
│  │       --no-log-prefix                    hide service name prefix
│  │       --index  N                         logs from instance N (scaled)
│  │
│  ├─── docker compose top  [service…]
│  │       (shows running processes per service)
│  │
│  ├─── docker compose events  [service…]
│  │       --json                             output as JSON stream
│  │       --dry-run
│  │
│  └─── docker compose port  <service>  <private_port>
│           --protocol  ▸ tcp|udp             (default tcp)
│           --index     N                     instance N of scaled service
│
├──────────────────────────────────────────────────────────────
│  INTERACT
├──────────────────────────────────────────────────────────────
│
│  ┌─── docker compose exec  <service>  <command>
│  │    ★ -it                                 interactive + TTY (default for TTY)
│  │    ★ -d  / --detach                      background
│  │    ★ -e  / --env  KEY=VALUE
│  │       -u  / --user
│  │       -w  / --workdir
│  │       -T  / --no-TTY                     disable TTY (for piping/scripts)
│  │       --index  N                         target instance N of scaled service
│  │       --privileged
│  │       --dry-run
│  │
│  └─── docker compose run  <service>  [command]
│       ★ --rm                                auto-remove after run
│       ★ -d  / --detach
│       ★ -e  / --env  KEY=VALUE
│       ★ --no-deps                           don't start dependency services
│          -it
│          --name     container-name
│          -p  / --publish  host:container
│          -v  / --volume   host:container
│          -u  / --user
│          -w  / --workdir
│          -T  / --no-TTY
│          --entrypoint  /bin/sh
│          --use-aliases                      use service aliases in network
│          --quiet-pull
│          --dry-run
│          -l  / --label
│
├──────────────────────────────────────────────────────────────
│  CONFIG & PROJECT
├──────────────────────────────────────────────────────────────
│
│  ┌─── docker compose config
│  │    ★ --services                          list service names
│  │    ★ --volumes                           list volume names
│  │       --profiles                         list profiles
│  │       --images                           list image names
│  │       --format  ▸ yaml|json
│  │       --output  file.yml                 write to file
│  │       --no-interpolate                   don't expand ${VAR}
│  │       --resolve-image-digests            pin image digests
│  │       -q  / --quiet                      validate only; no output
│  │
│  ├─── docker compose ls
│  │    ★ -a  / --all                         show stopped projects
│  │       -q  / --quiet
│  │       --format  ▸ table|json
│  │       --filter  status=▸ running|paused|exited
│  │
│  ├─── docker compose kill  [service…]
│  │       -s  / --signal  ▸ SIGTERM|SIGKILL|SIGHUP|SIGUSR1
│  │       --remove-orphans
│  │       --dry-run
│  │
│  └─── docker compose rm  [service…]
│           -f  / --force                     no confirmation
│           -s  / --stop                      stop containers before removing
│           -v  / --volumes                   remove anonymous volumes
│           --dry-run
│
└──────────────────────────────────────────────────────────────
```

---

## Common Flag Patterns (memorise these)

```
Pattern                       Docker run          Compose equivalent
──────────────────────────────────────────────────────────────────────
Background                    -d                  up -d
Interactive shell             -it image /bin/sh   exec -it svc /bin/sh
Remove on exit                --rm                run --rm svc cmd
Named container               --name foo          (service name = container name)
Port mapping                  -p 8080:80          ports: - "8080:80"
Env variable                  -e KEY=val          environment: KEY: val
Env file                      --env-file .env     env_file: - .env
Bind mount                    -v $(pwd):/app       volumes: - .:/app
Named volume                  -v data:/data        volumes: - data:/data
Network                       --network mynet     networks: - mynet
Restart always                --restart always    restart: always
Memory limit                  -m 512m             mem_limit: 512m
CPU limit                     --cpus 0.5          cpus: 0.5
Follow logs                   logs -f name        compose logs -f svc
Stream stats                  stats               (no direct equivalent)
Force rebuild + restart       rmi + run           compose up --build --force-recreate
Clean everything              system prune -a -f  down -v + system prune -a -f
```

---

## Compose File Structure Cross-Reference

```yaml
# docker-compose.yml top-level keys
version:    "3.9"           # legacy; omit for Compose Spec

services:
  web:                      # → docker compose [cmd] web
    image:      nginx:alpine
    build:                  # triggers: compose build
      context:  .
      dockerfile: Dockerfile.prod
      args:     { ENV: prod }
      target:   runner
      cache_from: [myimage:cache]
    ports:      ["8080:80"] # ← -p
    environment: { KEY: val }# ← -e
    env_file:   [.env]      # ← --env-file
    volumes:    [./app:/app]# ← -v
    networks:   [frontend]  # ← --network
    depends_on:
      db: { condition: service_healthy }
    restart:    unless-stopped  # ← --restart
    deploy:
      replicas: 3           # ← --scale web=3
      resources:
        limits: { cpus: "0.5", memory: 512M }
    healthcheck:
      test: ["CMD","curl","-f","http://localhost/"]
      interval: 30s
      timeout:  10s
      retries:  3
    command:    ["uvicorn","app:main"]
    entrypoint: ["/bin/sh","-c"]
    user:       "1000:1000"
    working_dir: /app
    read_only:  true
    tmpfs:      [/tmp]
    logging:
      driver: json-file
      options: { max-size: "10m", max-file: "3" }
    profiles:   [prod]      # activated with --profile prod

volumes:
  data:                     # named volume; listed by: compose config --volumes
    driver: local

networks:
  frontend:                 # listed by: compose config
    driver: bridge
    external: false         # true = pre-existing; compose doesn't create/destroy

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

---

## Quick-Reference Cheat Sheet

```
Goal                                          Command
────────────────────────────────────────────────────────────────────────────────
Run image interactively and remove            docker run --rm -it ubuntu /bin/bash
Run detached with name + ports + restart      docker run -d --name app -p 80:80 --restart unless-stopped nginx
Exec shell in running container               docker exec -it mycontainer /bin/bash
Tail last 100 lines + follow                  docker logs -f --tail 100 mycontainer
Copy file out of container                    docker cp mycontainer:/etc/nginx/nginx.conf ./nginx.conf
Build with custom file + no-cache             docker build -t myapp:v2 -f Dockerfile.prod --no-cache .
Remove all stopped containers                 docker rm $(docker ps -aq -f status=exited)
Remove all dangling images                    docker image prune -f
Full system clean                             docker system prune -a -f --volumes
List containers with format                   docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Inspect container IP                          docker inspect -f '{{.NetworkSettings.IPAddress}}' mycontainer
────────────────────────────────────────────────────────────────────────────────
Start services in background                  docker compose up -d
Force rebuild and restart                     docker compose up -d --build --force-recreate
Tear down + remove volumes                    docker compose down -v --remove-orphans
Stream all service logs                       docker compose logs -f
Run one-off command in service                docker compose run --rm web python manage.py migrate
Scale a service to 3                          docker compose up -d --scale web=3
Exec into specific scaled instance            docker compose exec --index 2 web /bin/bash
Validate compose file                         docker compose config -q
Show running projects                         docker compose ls
Rebuild single service only                   docker compose build --no-cache web && docker compose up -d web
────────────────────────────────────────────────────────────────────────────────
```
