# Docker for React Developers - Complete Guide

## Table of Contents
- [Introduction](#introduction)
- [Docker Fundamentals](#docker-fundamentals)
- [Docker for React - Getting Started](#docker-for-react---getting-started)
- [Dockerfile Best Practices](#dockerfile-best-practices)
- [Multi-Stage Builds](#multi-stage-builds)
- [Docker Compose](#docker-compose)
- [Development Workflows](#development-workflows)
- [CI/CD Integration](#cicd-integration)
- [Azure Deployment - Static Web Apps & Front Door](#azure-deployment---static-web-apps--front-door)
- [Security Best Practices](#security-best-practices)
- [Performance Optimization](#performance-optimization)
- [Networking in Docker](#networking-in-docker)
- [Debugging & Troubleshooting](#debugging--troubleshooting)
- [Production Deployment Strategies](#production-deployment-strategies)
- [Real-World Scenarios](#real-world-scenarios)
- [Common Pitfalls & Solutions](#common-pitfalls--solutions)

---

## Introduction

### What is Docker?
Docker is a platform for developing, shipping, and running applications in containers. Containers package an application with all its dependencies, ensuring consistency across different environments.

### Why Docker for React?
- **Consistency**: Same Node.js environment across dev, test, and production
- **Isolation**: Multiple React apps with different Node versions without conflicts
- **Reproducible Builds**: Identical build environment eliminates "works on my machine"
- **Portability**: Container runs anywhere - AWS, Azure, GCP, on-premises
- **Development Experience**: Hot reload, consistent tooling across team
- **CI/CD Integration**: Automated builds and deployments
- **Static Hosting**: Build optimized production bundles in containers

### Prerequisites
- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- Node.js (16.x, 18.x, or 20.x)
- npm or yarn package manager
- Basic command-line knowledge
- Understanding of React project structure (create-react-app, Vite, Next.js)

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

## Docker for React - Getting Started

### Basic Dockerfile for React App (Development)

```dockerfile
# Basic Dockerfile for Development (Not optimized - for learning purposes only)
# This simple example shows minimal requirements for running React dev server

# FROM: Specifies the base image - official Node.js image
# node:20-alpine: Node.js version 20 on Alpine Linux (lightweight)
FROM node:20-alpine

# WORKDIR: Sets the working directory inside the container
# All subsequent commands will run from this directory
# If the directory doesn't exist, it will be created
WORKDIR /app

# COPY: Copy package files first (for better layer caching)
# When only code changes (not dependencies), Docker reuses the install layer
COPY package.json package-lock.json ./

# RUN: Install dependencies
# npm ci: Clean install from package-lock.json (faster, more reliable than npm install)
RUN npm ci

# COPY: Copy all application source code
COPY . .

# EXPOSE: Documents which port the app uses (metadata only)
# React dev server typically runs on port 3000
EXPOSE 3000

# CMD: Default command when container starts
# npm start: Runs the development server with hot reload
CMD ["npm", "start"]
```

### Build and Run Commands

```bash
# Build Docker image
docker build -t my-react-app:dev .

# Run container with volume mount (for hot reload)
docker run -d \
  -p 3000:3000 \
  -v $(pwd)/src:/app/src \
  --name react-dev \
  my-react-app:dev

# View logs
docker logs -f react-dev

# Open browser
# Navigate to http://localhost:3000

# Stop container
docker stop react-dev
```

---

## Dockerfile Best Practices

### 1. **Multi-Stage Build Pattern** (Recommended for Production)

```dockerfile
# =============================================================================
# MULTI-STAGE BUILD - Best practice for production React applications
# =============================================================================
# Benefits:
# - Smaller final image (only static files + nginx, not Node.js)
# - Better layer caching (faster rebuilds)
# - Secure (build tools not in production image)
# - Serves static files efficiently with nginx
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Build React Application
# -----------------------------------------------------------------------------
# FROM: Use Node.js image for building
# AS build: Names this stage "build" for reference in later stages
# node:20-alpine: Lightweight Alpine Linux with Node.js 20
FROM node:20-alpine AS build

# WORKDIR: Set working directory for build operations
WORKDIR /app

# -----------------------------------------------------------------------------
# Copy package files FIRST (for Docker layer caching)
# -----------------------------------------------------------------------------
# Why separate from source code?
# - package.json and package-lock.json change less frequently than source
# - If only source changes, Docker reuses cached node_modules layer
# - This dramatically speeds up subsequent builds (10x faster)
COPY package.json package-lock.json ./

# -----------------------------------------------------------------------------
# Install dependencies
# -----------------------------------------------------------------------------
# RUN: Executes command during image build
# npm ci (Clean Install):
#   - Installs exactly what's in package-lock.json
#   - Faster than npm install
#   - More reliable for CI/CD
#   - Removes existing node_modules first
# This layer is cached until package*.json files change
RUN npm ci --only=production=false

# -----------------------------------------------------------------------------
# Copy source code
# -----------------------------------------------------------------------------
# Now copy all source files (src/, public/, etc.)
# Put this AFTER npm ci so changing code doesn't invalidate install cache
COPY . .

# -----------------------------------------------------------------------------
# Build the application for production
# -----------------------------------------------------------------------------
# RUN npm run build:
#   - Creates optimized production build
#   - Output goes to /app/build directory (create-react-app)
#   - Or /app/dist directory (Vite)
#   - Minifies JavaScript, CSS
#   - Optimizes images
#   - Creates static HTML/JS/CSS files
# 
# Build arguments for environment-specific builds:
ARG REACT_APP_API_URL
ARG REACT_APP_ENV=production

# Set build-time environment variables
ENV REACT_APP_API_URL=$REACT_APP_API_URL
ENV REACT_APP_ENV=$REACT_APP_ENV
ENV NODE_ENV=production

# Run the build
RUN npm run build

# -----------------------------------------------------------------------------
# Stage 2: Production Image with Nginx
# -----------------------------------------------------------------------------
# FROM: Use lightweight nginx image to serve static files
# nginx:alpine: Only ~20MB vs Node.js ~100MB
# Alpine is minimal Linux distribution for containers
FROM nginx:alpine AS production

# -----------------------------------------------------------------------------
# Install curl for health checks
# -----------------------------------------------------------------------------
# apk: Alpine Package Keeper (Alpine's package manager)
#   add: Install packages
#   --no-cache: Don't cache the package index (saves ~5MB)
RUN apk add --no-cache curl

# -----------------------------------------------------------------------------
# Copy built static files from build stage
# -----------------------------------------------------------------------------
# COPY --from=build: Copy files from the "build" stage
# Source: /app/build (create-react-app output)
# Destination: /usr/share/nginx/html (nginx default web root)
# Result: Only static files in final image, no Node.js or source code
COPY --from=build /app/build /usr/share/nginx/html

# -----------------------------------------------------------------------------
# Copy custom nginx configuration
# -----------------------------------------------------------------------------
# This handles:
#   - Single Page Application routing (all routes → index.html)
#   - Gzip compression
#   - Caching headers
#   - Security headers
COPY nginx.conf /etc/nginx/conf.d/default.conf

# -----------------------------------------------------------------------------
# Create non-root user for security
# -----------------------------------------------------------------------------
# nginx:x:101:101: Create nginx user with UID/GID 101
# This is security best practice - don't run as root
RUN adduser -D -u 101 -g nginx nginx || true

# Change ownership of nginx directories to non-root user
RUN chown -R nginx:nginx /usr/share/nginx/html \
    && chown -R nginx:nginx /var/cache/nginx \
    && chown -R nginx:nginx /var/log/nginx \
    && touch /var/run/nginx.pid \
    && chown -R nginx:nginx /var/run/nginx.pid

# Switch to non-root user
# USER: All subsequent commands run as this user
USER nginx

# -----------------------------------------------------------------------------
# Expose port 80 (HTTP)
# -----------------------------------------------------------------------------
# EXPOSE: Documents which port nginx listens on
# Note: This is metadata only; use -p flag in docker run to publish
EXPOSE 80

# -----------------------------------------------------------------------------
# Health check configuration
# -----------------------------------------------------------------------------
# HEALTHCHECK: Docker periodically runs this to check container health
#   --interval=30s: Check every 30 seconds
#   --timeout=3s: Each check must complete within 3 seconds
#   --start-period=5s: Wait 5 seconds before first check
#   --retries=3: Mark unhealthy after 3 consecutive failures
# curl -f: Fail on HTTP errors (4xx, 5xx)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# -----------------------------------------------------------------------------
# Start nginx
# -----------------------------------------------------------------------------
# CMD: Default command when container starts
# nginx -g 'daemon off;': Run nginx in foreground
#   - daemon off: Keep nginx in foreground (required for Docker)
#   - Without this, container would exit immediately
CMD ["nginx", "-g", "daemon off;"]
```

### nginx.conf for React SPA

```nginx
# /nginx.conf
# Nginx configuration for React Single Page Applications

server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    # Gzip compression for better performance
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    gzip_min_length 1000;
    gzip_comp_level 6;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Cache static assets (JS, CSS, images)
    location ~* \.(?:css|js|jpg|jpeg|gif|png|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # SPA routing: serve index.html for all routes
    # This allows React Router to handle routes client-side
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}

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

### 3. **Ultra-Lightweight with Vite (Modern Build Tool)**

```dockerfile
# =============================================================================
# VITE BUILD - Modern, fast build tool for React
# =============================================================================
# Vite benefits:
# - Faster builds (10x faster than CRA)
# - Better tree-shaking (smaller bundles)
# - Built-in TypeScript support
# - Hot Module Replacement (HMR) during development
# =============================================================================

# -----------------------------------------------------------------------------
# Build stage with Vite
# -----------------------------------------------------------------------------
# Using Alpine for minimal base image
FROM node:20-alpine AS build

WORKDIR /app

# -----------------------------------------------------------------------------
# Install dependencies
# -----------------------------------------------------------------------------
# Copy package files
COPY package.json package-lock.json ./

# npm ci: Clean install from lockfile
RUN npm ci

# -----------------------------------------------------------------------------
# Copy source and build with Vite
# -----------------------------------------------------------------------------
COPY . .

# Vite build:
#   - Output goes to /app/dist (Vite default)
#   - Smaller bundles due to better tree-shaking
#   - Faster build times with esbuild
ENV NODE_ENV=production
RUN npm run build

# Show build stats
RUN echo "Vite build complete:" && \
    ls -lh dist/ && \
    du -sh dist/

# -----------------------------------------------------------------------------
# Production stage with nginx
# -----------------------------------------------------------------------------
# Smallest possible production image
FROM nginx:alpine AS production

# Install curl for health checks
RUN apk add --no-cache curl

# -----------------------------------------------------------------------------
# Copy Vite build output
# -----------------------------------------------------------------------------
# Note: Vite outputs to 'dist' not 'build'
COPY --from=build /app/dist /usr/share/nginx/html

# Copy nginx config for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose HTTP port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```

### vite.config.ts Example

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  
  // Build optimization
  build: {
    outDir: 'dist',
    sourcemap: false, // Disable for production
    minify: 'esbuild',
    
    // Split chunks for better caching
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom', 'react-router-dom'],
        },
      },
    },
    
    // Chunk size warnings
    chunkSizeWarningLimit: 1000,
  },
  
  // Development server
  server: {
    host: '0.0.0.0', // Listen on all interfaces (for Docker)
    port: 3000,
    strictPort: true,
  },
  
  // Path aliases
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
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

For React applications, multi-stage builds separate build, test, and production stages.

```dockerfile
# =============================================================================
# ADVANCED MULTI-STAGE BUILD WITH INTEGRATED TESTING
# =============================================================================
# This Dockerfile demonstrates:
#   - Separate stages for dependencies, build, test, and production
#   - Running tests as part of the build process
#   - Using --target flag to build specific stages
#   - Ensuring code quality before deployment
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Dependencies (base for all other stages)
# -----------------------------------------------------------------------------
# FROM ... AS dependencies: Name this stage "dependencies"
# Separating dependencies allows better caching granularity
FROM node:20-alpine AS dependencies

WORKDIR /app

# Copy package files
# This stage caches until package.json or package-lock.json changes
COPY package.json package-lock.json ./

# Install ALL dependencies (including devDependencies for testing)
# npm ci: Clean install from package-lock.json
# This layer is reused until any package file changes
RUN npm ci

# -----------------------------------------------------------------------------
# Stage 2: Build
# -----------------------------------------------------------------------------
# FROM dependencies AS build: Start from dependencies stage
FROM dependencies AS build

# Copy all source code
# Now that dependencies are installed, bring in the code
COPY . .

# Build the application
# Creates optimized production build
ENV NODE_ENV=production
RUN npm run build

# Display build size for monitoring
RUN du -sh /app/build || du -sh /app/dist

# -----------------------------------------------------------------------------
# Stage 3: Test (critical for CI/CD)
# -----------------------------------------------------------------------------
# FROM dependencies AS test: Start from dependencies stage
# Named "test" so can target with: docker build --target test
FROM dependencies AS test

# Copy source code
COPY . .

# Run tests
# If tests FAIL, the Docker build FAILS
# This prevents deploying broken code
RUN npm test -- --coverage --watchAll=false
ENV CI=true

# Note: Test results and coverage are in this stage
# To extract: docker create --name test-container react-app:test
#            docker cp test-container:/app/coverage ./coverage
#            docker rm test-container

# -----------------------------------------------------------------------------
# Stage 4: Production (nginx serves static files)
# -----------------------------------------------------------------------------
# FROM nginx:alpine AS production: Lightweight nginx for serving
# Only contains built static files, not source code or node_modules
FROM nginx:alpine AS production

# Install curl for health checks
RUN apk add --no-cache curl

# Copy built static files from build stage
# Note: Change 'build' to 'dist' if using Vite
COPY --from=build /app/build /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create non-root nginx user
RUN adduser -D -u 101 -g nginx nginx || true && \
    chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

# Switch to non-root user
USER nginx

# Expose HTTP port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

# =============================================================================
# BUILD COMMANDS:
# =============================================================================
# Test only (CI pipeline):
#   docker build --target test -t my-react-app:test .
#
# Full build with tests (build fails if tests fail):
#   docker build -t my-react-app:prod .
#   (Tests run automatically during build, but final image doesn't include them)
#
# Skip tests (not recommended for production):
#   docker build --target production -t my-react-app:prod .
#   (Skips test stage)
#
# Extract test results:
#   docker build --target test -t my-react-app:test .
#   docker create --name temp my-react-app:test
#   docker cp temp:/app/coverage ./coverage
#   docker rm temp
# =============================================================================
```

### Multi-Target Dockerfile - Development and Production

Single Dockerfile that can build both development and production images:

```dockerfile
# =============================================================================
# MULTI-TARGET DOCKERFILE - Development and Production in One File
# =============================================================================
# Single Dockerfile that can build:
#   1. Development image (with hot reload)
#   2. Production image (optimized static files with nginx)
# =============================================================================

# -----------------------------------------------------------------------------
# Development image (Stage 1) - Full Node.js for development workflow
# -----------------------------------------------------------------------------
# FROM ... AS development: Name this stage "development"
# Target with: docker build --target development -t my-react-app:dev .
FROM node:20-alpine AS development

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including devDependencies)
RUN npm install

# Copy all source files (in dev, we want everything)
COPY . .

# -----------------------------------------------------------------------------
# Environment variables for development
# -----------------------------------------------------------------------------
# Enable polling for file watching in containers (especially on Windows/Mac)
ENV CHOKIDAR_USEPOLLING=true
ENV REACT_APP_ENV=development
ENV NODE_ENV=development

# Expose development server port
EXPOSE 3000

# -----------------------------------------------------------------------------
# Entry point for development with hot reload
# -----------------------------------------------------------------------------
# ENTRYPOINT: Start development server with hot reload
# npm start: Runs React development server
#   - Monitors for file changes
#   - Automatically recompiles and hot-reloads
#   - Essential for dev productivity
# Use with volume mount:
#   docker run -v $(pwd)/src:/app/src -v $(pwd)/public:/app/public my-react-app:dev
# When you edit files on host, app automatically reloads
CMD ["npm", "start"]

# =============================================================================
# Build stages for production
# =============================================================================

# -----------------------------------------------------------------------------
# Install production dependencies only
# -----------------------------------------------------------------------------
FROM node:20-alpine AS prod-dependencies

WORKDIR /app

COPY package*.json ./

# Install ONLY production dependencies (no devDependencies)
# Smaller node_modules, faster builds
RUN npm ci --only=production

# -----------------------------------------------------------------------------
# Build stage - Create optimized production bundle
# -----------------------------------------------------------------------------
FROM node:20-alpine AS build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (need devDependencies for build)
RUN npm ci

# Copy source code
COPY . .

# Build arguments for environment-specific builds
ARG REACT_APP_API_URL
ARG REACT_APP_ENV=production

# Set build-time environment variables
ENV REACT_APP_API_URL=$REACT_APP_API_URL
ENV REACT_APP_ENV=$REACT_APP_ENV
ENV NODE_ENV=production

# Build the application
# Creates optimized production build
RUN npm run build

# Display build statistics
RUN echo "Production build complete. Size:" && \
    du -sh build/ 2>/dev/null || du -sh dist/ 2>/dev/null

# -----------------------------------------------------------------------------
# Final production image - Nginx serves static files
# -----------------------------------------------------------------------------
# FROM ... AS production: Name this stage "production"
# Target with: docker build --target production -t my-react-app:prod .
# or simply: docker build -t my-react-app:prod . (production is the default)
FROM nginx:alpine AS production

# Install curl for health checks
RUN apk add --no-cache curl

# Copy built static files from build stage
# Note: Change path if using Vite (dist instead of build)
COPY --from=build /app/build /usr/share/nginx/html

# Copy nginx configuration for React SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create non-root user and set ownership
RUN adduser -D -u 101 -g nginx nginx || true && \
    chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

# Switch to non-root user (security best practice)
USER nginx

# Expose HTTP port
EXPOSE 80

# Health check configuration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]

# =============================================================================
# USAGE EXAMPLES:
# =============================================================================
#
# Build development image:
#   docker build --target development -t my-react-app:dev .
#   docker run -p 3000:3000 -v $(pwd)/src:/app/src my-react-app:dev
#
# Build production image (default):
#   docker build -t my-react-app:prod .
#   docker run -p 80:80 my-react-app:prod
#
# Build with environment variables:
#   docker build \
#     --build-arg REACT_APP_API_URL=https://api.example.com \
#     -t my-react-app:prod .
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

## Azure Deployment - Static Web Apps & Front Door

### Overview

This section covers deploying React applications to Azure using two modern approaches:

1. **Azure Static Web Apps (SWA)**: Global CDN-backed hosting for static sites
2. **Azure Front Door**: Enterprise-grade CDN with advanced routing and caching
3. **CI/CD Integration**: GitHub Actions or Azure Pipelines for automated deployments
4. **Docker Build**: Optional containerized builds for consistency

### Why Azure Static Web Apps + Front Door?

**Azure Static Web Apps Benefits:**
- ✅ Built-in global CDN (no configuration needed)
- ✅ Free SSL certificates
- ✅ GitHub/GitLab integration (automatic deployments)
- ✅ Preview environments for pull requests
- ✅ Serverless API integration (Azure Functions)
- ✅ Custom domains with automatic DNS
- ✅ Built-in authentication (AAD, GitHub, Twitter, etc.)

**Azure Front Door Benefits:**
- ✅ Enterprise-grade global CDN
- ✅ Advanced routing rules and URL rewrites
- ✅ WAF (Web Application Firewall) integration
- ✅ Traffic acceleration and caching
- ✅ Multi-region failover
- ✅ Real-time analytics
- ✅ DDoS protection

### Architecture Flow

```
┌──────────────────────┐
│    Source Code       │
│  (GitHub/Azure Repos)│
└──────────┬───────────┘
           │
           ▼
┌──────────────────────────────────────────────────────┐
│         CI/CD Pipeline (GitHub Actions)              │
│  ┌───────────┐  ┌────────────┐  ┌────────────────┐  │
│  │  Docker   │─▶│  Build     │─▶│  Deploy to     │  │
│  │  Build    │  │  React App │  │  Static Web    │  │
│  │  (Optional)│  │            │  │  Apps          │  │
│  └───────────┘  └────────────┘  └────────────────┘  │
└──────────────────────────────────────────────────────┘
           │                                   │
           ▼                                   ▼
┌──────────────────────┐          ┌────────────────────┐
│  Azure Storage       │          │  Azure Static      │
│  (Build Artifacts)   │          │  Web Apps          │
│                      │          │  - Global CDN      │
│                      │          │  - Free SSL        │
│                      │          │  - Auto-deploy     │
└──────────────────────┘          └──────────┬─────────┘
                                             │
                                             ▼
                                  ┌────────────────────┐
                                  │  Azure Front Door  │
                                  │  - WAF             │
                                  │  - Caching         │
                                  │  - Routing         │
                                  └────────────────────┘
```

---

### Method 1: Azure Static Web Apps (Recommended for React)

#### Prerequisites

```bash
# Install Azure CLI (if not already installed)
# Windows: winget install Microsoft.AzureCLI
# Mac: brew install azure-cli
# Linux: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Static Web Apps CLI for local testing
npm install -g @azure/static-web-apps-cli

# Login to Azure
az login

# Set subscription (if you have multiple)
az account set --subscription "Your-Subscription-Name"
```

#### Step 1: Create Azure Static Web App via Azure Portal

1. Navigate to [Azure Portal](https://portal.azure.com)
2. Click "+ Create a resource"
3. Search for "Static Web Apps"
4. Fill in details:
   - **Subscription**: Your subscription
   - **Resource Group**: Create new or select existing
   - **Name**: `my-react-app` (DNS-safe name)
   - **Plan**: Free (for development) or Standard (for production)
   - **Region**: Choose closest to your users
   - **Source**: GitHub or Azure DevOps
5. Sign in to GitHub and authorize Azure
6. Select:
   - **Organization**: Your GitHub org
   - **Repository**: Your React repo
   - **Branch**: `main` or `master`
7. Build Presets: **React**
8. Build Details:
   - **App location**: `/` (root of repo)
   - **API location**: `/api` (if using Azure Functions)
   - **Output location**: `build` (for CRA) or `dist` (for Vite)
9. Click "Review + Create"

#### Step 2: Create via Azure CLI

```bash
# Variables
RESOURCE_GROUP="rg-my-react-app"
LOCATION="eastus2"
SWA_NAME="my-react-app"
GITHUB_REPO="https://github.com/your-org/your-repo"
BRANCH="main"

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create Static Web App
az staticwebapp create \
  --name $SWA_NAME \
  --resource-group $RESOURCE_GROUP \
  --source $GITHUB_REPO \
  --location $LOCATION \
  --branch $BRANCH \
  --app-location "/" \
  --output-location "build" \
  --login-with-github

# Get deployment token (for CI/CD)
DEPLOYMENT_TOKEN=$(az staticwebapp secrets list \
  --name $SWA_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "properties.apiKey" \
  --output tsv)

echo "Deployment Token: $DEPLOYMENT_TOKEN"
# Save this token - you'll need it for GitHub Actions
```

---

### Method 2: GitHub Actions for Static Web Apps

Azure Static Web Apps automatically creates a GitHub Actions workflow file when you link your repository. Here's the generated workflow with explanations:

#### .github/workflows/azure-static-web-apps.yml

```yaml
# =============================================================================
# GITHUB ACTIONS WORKFLOW - AZURE STATIC WEB APPS DEPLOYMENT
# =============================================================================
# Automatically generated by Azure, customized for React + Docker build
# This workflow:
#   1. Builds React app (optionally in Docker)
#   2. Runs tests
#   3. Deploys to Azure Static Web Apps
#   4. Creates preview environments for PRs
# =============================================================================

name: Azure Static Web Apps CI/CD

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches:
      - main

# Environment variables
env:
  NODE_VERSION: '20.x'
  REACT_APP_API_URL: ${{ secrets.REACT_APP_API_URL }}

jobs:
  # ===========================================================================
  # JOB 1: BUILD AND DEPLOY
  # ===========================================================================
  build_and_deploy_job:
    # Only run if PR is not being closed
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.action != 'closed')
    runs-on: ubuntu-latest
    name: Build and Deploy Job
    
    steps:
      # -----------------------------------------------------------------------
      # Checkout code
      # -----------------------------------------------------------------------
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          submodules: true
          lfs: false

      # -----------------------------------------------------------------------
      # Optional: Build with Docker (for consistency)
      # -----------------------------------------------------------------------
      - name: Build with Docker
        if: false  # Set to 'true' to enable Docker build
        run: |
          docker build \
            --build-arg REACT_APP_API_URL=${{ secrets.REACT_APP_API_URL }} \
            --target build \
            -t react-build:${{ github.sha }} \
            .
          
          # Extract build artifacts from Docker image
          docker create --name temp-container react-build:${{ github.sha }}
          docker cp temp-container:/app/build ./build
          docker rm temp-container

      # -----------------------------------------------------------------------
      # Standard Node.js build (alternative to Docker)
      # -----------------------------------------------------------------------
      - name: Set up Node.js
        if: true  # Set to 'false' if using Docker build above
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        if: true
        run: npm ci

      - name: Run tests
        if: true
        run: npm test -- --coverage --watchAll=false
        env:
          CI: true

      - name: Build application
        if: true
        run: npm run build
        env:
          REACT_APP_API_URL: ${{ secrets.REACT_APP_API_URL }}
          REACT_APP_ENV: production
          NODE_ENV: production

      # -----------------------------------------------------------------------
      # Deploy to Azure Static Web Apps
      # -----------------------------------------------------------------------
      - name: Deploy to Azure Static Web Apps
        id: deploy
        uses: Azure/static-web-apps-deploy@v1
        with:
          # Azure Static Web Apps deployment token (stored in GitHub Secrets)
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          
          # Repository/build configuration
          repo_token: ${{ secrets.GITHUB_TOKEN }} # For commenting on PRs
          action: "upload"
          
          # App build settings
          app_location: "/" # App source code path
          api_location: "api" # API source code path (if using Azure Functions)
          output_location: "build" # Built app folder (change to 'dist' for Vite)
          
          # Skip API build if no serverless functions
          skip_api_build: false

  # ===========================================================================
  # JOB 2: CLOSE PR (Cleanup preview environment)
  # ===========================================================================
  close_pull_request_job:
    if: github.event_name == 'pull_request' && github.event.action == 'closed'
    runs-on: ubuntu-latest
    name: Close Pull Request Job
    
    steps:
      - name: Close Pull Request
        id: closepullrequest
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          action: "close"
```

#### Secrets Configuration

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

1. **AZURE_STATIC_WEB_APPS_API_TOKEN**
   - Get from Azure Portal: Static Web App → Manage deployment token
   - Or via CLI: `az staticwebapp secrets list --name <app-name> --resource-group <rg-name>`

2. **REACT_APP_API_URL**
   - Your backend API URL
   - Example: `https://api.example.com`

3. **REACT_APP_* (any other environment variables)**
   - All your React environment variables

---

### Method 3: Azure DevOps Pipeline for Static Web Apps

#### azure-pipelines.yml

```yaml
# =============================================================================
# AZURE DEVOPS PIPELINE - STATIC WEB APPS DEPLOYMENT
# =============================================================================
# This pipeline:
#   1. Builds React app in Docker (optional)
#   2. Runs tests
#   3. Deploys to Azure Static Web Apps
# =============================================================================

trigger:
  branches:
    include:
      - main
      - develop
  paths:
    exclude:
      - README.md
      - docs/*

pr:
  branches:
    include:
      - main
  
variables:
  # Build configuration
  nodeVersion: '20.x'
  buildOutputPath: 'build'  # Change to 'dist' for Vite
  
  # Azure Static Web Apps
  azureStaticWebAppName: 'my-react-app'
  resourceGroup: 'rg-my-react-app'
  
  # Environment variables for build
  REACT_APP_API_URL: $(ReactAppApiUrl)  # Defined in pipeline variables
  REACT_APP_ENV: 'production'

pool:
  vmImage: 'ubuntu-latest'

stages:
  # ===========================================================================
  # STAGE 1: BUILD & TEST
  # ===========================================================================
  - stage: Build
    displayName: 'Build and Test'
    jobs:
      - job: BuildJob
        displayName: 'Build React Application'
        steps:
          # -----------------------------------------------------------------
          # Option A: Standard Node.js build
          # -----------------------------------------------------------------
          - task: NodeTool@0
            displayName: 'Install Node.js'
            inputs:
              versionSpec: '$(nodeVersion)'

          - script: npm ci
            displayName: 'Install Dependencies'

          - script: npm run test -- --coverage --watchAll=false
            displayName: 'Run Tests'
            env:
              CI: true

          - script: npm run build
            displayName: 'Build React App'
            env:
              REACT_APP_API_URL: $(REACT_APP_API_URL)
              REACT_APP_ENV: $(REACT_APP_ENV)
              NODE_ENV: production

          # -----------------------------------------------------------------
          # Option B: Docker build (alternative)
          # -----------------------------------------------------------------
          - task: Docker@2
            displayName: 'Build with Docker'
            enabled: false  # Set to 'true' to use Docker build
            inputs:
              command: 'build'
              Dockerfile: '**/Dockerfile'
              tags: '$(Build.BuildId)'
              arguments: |
                --build-arg REACT_APP_API_URL=$(REACT_APP_API_URL)
                --target build

          # -----------------------------------------------------------------
          # Publish build artifacts
          # -----------------------------------------------------------------
          - task: PublishBuildArtifacts@1
            displayName: 'Publish Build Artifacts'
            inputs:
              PathtoPublish: '$(System.DefaultWorkingDirectory)/$(buildOutputPath)'
              ArtifactName: 'build'
              publishLocation: 'Container'

  # ===========================================================================
  # STAGE 2: DEPLOY TO AZURE STATIC WEB APPS
  # ===========================================================================
  - stage: Deploy
    displayName: 'Deploy to Azure Static Web Apps'
    dependsOn: Build
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployToSWA
        displayName: 'Deploy to Static Web Apps'
        environment: 'production'
        strategy:
          runOnce:
            deploy:
              steps:
                # -------------------------------------------------------
                # Download build artifacts
                # -------------------------------------------------------
                - task: DownloadBuildArtifacts@1
                  inputs:
                    buildType: 'current'
                    downloadType: 'single'
                    artifactName: 'build'
                    downloadPath: '$(System.ArtifactsDirectory)'

                # -------------------------------------------------------
                # Deploy to Azure Static Web Apps
                # -------------------------------------------------------
                - task: AzureStaticWebApp@0
                  displayName: 'Deploy to Static Web Apps'
                  inputs:
                    app_location: '$(System.ArtifactsDirectory)/build'
                    # api_location: 'api'  # Uncomment if using Azure Functions
                    output_location: ''
                    azure_static_web_apps_api_token: $(AZURE_STATIC_WEB_APPS_API_TOKEN)

  # ===========================================================================
  # STAGE 3: SMOKE TESTS
  # ===========================================================================
  - stage: SmokeTests
    displayName: 'Run Smoke Tests'
    dependsOn: Deploy
    condition: succeeded()
    jobs:
      - job: SmokeTestsJob
        displayName: 'Execute Smoke Tests'
        steps:
          - script: |
              # Get Static Web App URL
              SWA_URL=$(az staticwebapp show \
                --name $(azureStaticWebAppName) \
                --resource-group $(resourceGroup) \
                --query "defaultHostname" \
                --output tsv)
              
              echo "Testing app at: https://$SWA_URL"
              
              # Test homepage
              HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://$SWA_URL)
              
              if [ $HTTP_STATUS -eq 200 ]; then
                echo "✅ Smoke test passed! App is running."
              else
                echo "❌ Smoke test failed! HTTP Status: $HTTP_STATUS"
                exit 1
              fi
            displayName: 'Run Smoke Tests'
            env:
              AZURE_DEVOPS_EXT_PAT: $(System.AccessToken)
```

---

### Method 4: Azure Front Door Configuration

Azure Front Door provides enterprise-grade CDN, WAF, and advanced routing capabilities for your React app.

#### Step 1: Create Azure Front Door

```bash
# Variables
RESOURCE_GROUP="rg-my-react-app"
LOCATION="global" # Front Door is a global service
FRONTDOOR_NAME="myreactapp-fd"
SWA_HOSTNAME="your-swa-app.azurestaticapps.net"  # From Static Web App

# Create Front Door profile (Premium SKU for StaticWeb Apps)
az afd profile create \
  --profile-name $FRONTDOOR_NAME \
  --resource-group $RESOURCE_GROUP \
  --sku Premium_AzureFrontDoor

# Create endpoint
az afd endpoint create \
  --endpoint-name "${FRONTDOOR_NAME}-endpoint" \
  --profile-name $FRONTDOOR_NAME \
  --resource-group $RESOURCE_GROUP \
  --enabled-state Enabled

# Create origin group
az afd origin-group create \
  --origin-group-name "swa-origin-group" \
  --profile-name $FRONTDOOR_NAME \
  --resource-group $RESOURCE_GROUP \
  --probe-request-type GET \
  --probe-protocol Https \
  --probe-path "/" \
  --probe-interval-in-seconds 120 \
  --sample-size 4 \
  --successful-samples-required 3 \
  --additional-latency-in-milliseconds 50

# Add Static Web App as origin
az afd origin create \
  --host-name $SWA_HOSTNAME \
  --origin-group-name "swa-origin-group" \
  --origin-name "swa-origin" \
  --profile-name $FRONTDOOR_NAME \
  --resource-group $RESOURCE_GROUP \
  --enabled-state Enabled \
  --priority 1 \
  --weight 1000 \
  --http-port 80 \
  --https-port 443 \
  --origin-host-header $SWA_HOSTNAME

# Create route
az afd route create \
  --endpoint-name "${FRONTDOOR_NAME}-endpoint" \
  --profile-name $FRONTDOOR_NAME \
  --resource-group $RESOURCE_GROUP \
  --route-name "default-route" \
  --origin-group "swa-origin-group" \
  --supported-protocols Https Http \
  --https-redirect Enabled \
  --forwarding-protocol HttpsOnly \
  --patterns-to-match "/*"
```

#### Step 2: Configure WAF (Web Application Firewall)

```bash
# Create WAF policy
az network front-door waf-policy create \
  --name "${FRONTDOOR_NAME}-waf" \
  --resource-group $RESOURCE_GROUP \
  --sku Premium_AzureFrontDoor \
  --mode Prevention

# Configure managed rules (OWASP protection)
az network front-door waf-policy managed-rules add \
  --policy-name "${FRONTDOOR_NAME}-waf" \
  --resource-group $RESOURCE_GROUP \
  --type Microsoft_DefaultRuleSet \
  --version 2.1 \
  --action Block

# Add bot protection
az network front-door waf-policy managed-rules add \
  --policy-name "${FRONTDOOR_NAME}-waf" \
  --resource-group $RESOURCE_GROUP \
  --type Microsoft_BotManagerRuleSet \
  --version 1.0 \
  --action Block

# Configure rate limiting (prevent DDoS)
az network front-door waf-policy rule create \
  --policy-name "${FRONTDOOR_NAME}-waf" \
  --resource-group $RESOURCE_GROUP \
  --name "RateLimitRule" \
  --rule-type RateLimitRule \
  --rate-limit-duration 1 \
  --rate-limit-threshold 100 \
  --action Block \
  --priority 100

# Associate WAF with Front Door endpoint
az afd security-policy create \
  --profile-name $FRONTDOOR_NAME \
  --resource-group $RESOURCE_GROUP \
  --security-policy-name "waf-policy" \
  --domains "${FRONTDOOR_NAME}-endpoint.azurefd.net" \
  --waf-policy "/subscriptions/{sub-id}/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/frontdoorwebapplicationfirewallpolicies/${FRONTDOOR_NAME}-waf"
```

#### Step 3: Configure Custom Domain with Front Door

```bash
# Add custom domain to Front Door
CUSTOM_DOMAIN="www.yourdomain.com"

az afd custom-domain create \
  --custom-domain-name "www-yourdomain-com" \
  --profile-name $FRONTDOOR_NAME \
  --resource-group $RESOURCE_GROUP \
  --host-name $CUSTOM_DOMAIN \
  --certificate-type ManagedCertificate \
  --minimum-tls-version TLS12

# Get validation token
VALIDATION_TOKEN=$(az afd custom-domain show \
  --custom-domain-name "www-yourdomain-com" \
  --profile-name $FRONTDOOR_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "validationProperties.validationToken" \
  --output tsv)

echo "Add this TXT record to your DNS:"
echo "Name: _dnsauth.www"
echo "Value: $VALIDATION_TOKEN"

# After DNS propagates, associate domain with route
az afd route update \
  --endpoint-name "${FRONTDOOR_NAME}-endpoint" \
  --profile-name $FRONTDOOR_NAME \
  --resource-group $RESOURCE_GROUP \
  --route-name "default-route" \
  --custom-domains "www-yourdomain-com"
```

---

### Static Web App Configuration File

Create `staticwebapp.config.json` in the root of your React project:

```json
{
  "$schema": "https://json.schemastore.org/staticwebapp.config.json",
  
  "routes": [
    {
      "route": "/api/*",
      "rewrite": "/api/*"
    },
    {
      "route": "/login",
      "rewrite": "/index.html"
    },
    {
      "route": "/logout",
      "allowedRoles": ["authenticated"]
    }
  ],
  
  "navigationFallback": {
    "rewrite": "/index.html",
    "exclude": ["/images/*.{png,jpg,gif}", "/css/*", "/api/*"]
  },
  
  "responseOverrides": {
    "404": {
      "rewrite": "/index.html",
      "statusCode": 200
    }
  },
  
  "globalHeaders": {
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY",
    "X-XSS-Protection": "1; mode=block",
    "Referrer-Policy": "strict-origin-when-cross-origin",
    "Permissions-Policy": "geolocation=(), microphone=(), camera=()",
    "Content-Security-Policy": "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https://your-api.com"
  },
  
  "mimeTypes": {
    ".json": "application/json",
    ".wasm": "application/wasm"
  },
  
  "platform": {
    "apiRuntime": "node:18"
  },
  
  "networking": {
    "allowedIpRanges": ["0.0.0.0/0"]
  }
}
```

---

### Local Development with Static Web Apps CLI

```bash
# Install SWA CLI globally
npm install -g @azure/static-web-apps-cli

# Start development server
swa start http://localhost:3000 --api-location ./api

# With custom configuration
swa start build --api-location api --port 4280

# Login to Azure (for testing authentication)
swa login

# Deploy from CLI
swa deploy ./build \
  --deployment-token $AZURE_STATIC_WEB_APPS_API_TOKEN \
  --app-location . \
  --output-location build

# View logs
swa --help
```

---

### Performance Optimization for Azure

#### 1. **Enable Compression in nginx** (if using containers)

```nginx
# nginx.conf
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types
  text/plain
  text/css
  text/xml
  text/javascript
  application/x-javascript
  application/javascript
  application/xml+rss
  application/json
  application/vnd.ms-fontobject
  application/x-font-ttf
  font/opentype
  image/svg+xml
  image/x-icon;
```

#### 2. **Optimize React Build**

```javascript
// package.json - add optimization scripts
{
  "scripts": {
    "build": "react-scripts build",
    "build:analyze": "npm run build && npx source-map-explorer 'build/static/js/*.js'",
    "build:prod": "GENERATE_SOURCEMAP=false npm run build"
  }
}
```

#### 3. **Configure Caching Headers** (Static Web Apps)

```json
// staticwebapp.config.json
{
  "routes": [
    {
      "route": "/static/*",
      "headers": {
        "Cache-Control": "public, max-age=31536000, immutable"
      }
    },
    {
      "route": "/*.{png,jpg,jpeg,gif,svg,ico,webp}",
      "headers": {
        "Cache-Control": "public, max-age=31536000, immutable"
      }
    },
    {
      "route": "/*.{js,css}",
      "headers": {
        "Cache-Control": "public, max-age=31536000, immutable"
      }
    }
  ]
}
```

---

### Monitoring & Troubleshooting

#### View Static Web App Logs

```bash
# Stream logs
az staticwebapp show \
  --name $SWA_NAME \
  --resource-group $RESOURCE_GROUP

# Get deployment history
az staticwebapp environment list \
  --name $SWA_NAME \
  --resource-group $RESOURCE_GROUP

# View build logs (from GitHub Actions or Azure DevOps)
```

#### Front Door Diagnostics

```bash
# Enable diagnostics
az monitor diagnostic-settings create \
  --name "fd-diagnostics" \
  --resource "/subscriptions/{sub-id}/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Cdn/profiles/$FRONTDOOR_NAME" \
  --logs '[{"category":"FrontDoorAccessLog","enabled":true}, {"category":"FrontDoorHealthProbeLog","enabled":true"}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]' \
  --workspace "/subscriptions/{sub-id}/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}"

# View metrics
az monitor metrics list \
  --resource "/subscriptions/{sub-id}/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Cdn/profiles/$FRONTDOOR_NAME" \
  --metric-names "RequestCount" "OriginRequestCount" "OriginLatency"
```

#### Common Issues

**1. Static Web App Build Fails**
```bash
# Check build logs in GitHub Actions or Azure DevOps
# Common issues:
# - Wrong app_location or output_location in workflow
# - Missing environment variables
# - npm ci fails (delete package-lock.json and regenerate)

# Solution: Update workflow file
app_location: "/"
output_location: "build"  # or "dist" for Vite
```

**2. CORS Errors**
```json
// staticwebapp.config.json
{
  "globalHeaders": {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization"
  }
}
```

**3. 404 on Refresh (React Router)**
```json
// staticwebapp.config.json
{
  "navigationFallback": {
    "rewrite": "/index.html"
  }
}
```

---

### Best Practices Summary

#### Security
✅ Use Azure Front Door with WAF for production  
✅ Enable HTTPS redirect and minimum TLS 1.2  
✅ Configure security headers in staticwebapp.config.json  
✅ Use Azure Key Vault for API keys and secrets  
✅ Enable Azure AD authentication if needed  
✅ Configure rate limiting to prevent DDoS  

#### Performance
✅ Enable compression (gzip/brotli)  
✅ Configure aggressive caching for static assets  
✅ Use CDN (built-in with Static Web Apps)  
✅ Optimize bundle size (code splitting, tree-shaking)  
✅ Use image optimization and lazy loading  
✅ Enable Front Door caching rules  

#### Operations
✅ Use preview environments for PRs (automatic with SWA)  
✅ Implement proper monitoring with Application Insights  
✅ Configure custom domains with managed certificates  
✅ Use staging slots for zero-downtime deployments  
✅ Implement health checks and synthetic monitoring  
✅ Document rollback procedures  

#### Cost Optimization
✅ Use Free tier for personal/dev projects  
✅ Standard tier for production ($9/month)  
✅ Front Door Premium only if you need WAF/Private Link  
✅ Monitor bandwidth usage  
✅ Clean up preview environments after PR merge  

---

## Security Best Practices
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

#### Detailed Flow Explanation

**Step 1: Azure Pipeline Builds Image**
```yaml
# Pipeline authenticates using Service Connection
# Service Connection contains:
#   - Service Principal Client ID
#   - Service Principal Client Secret
#   - Tenant ID
#   - Subscription ID

# Docker@2 task uses these credentials to:
docker login myappacr.azurecr.io \
  -u <service-principal-id> \
  -p <service-principal-secret>
```

**Step 2: Image is Pushed to ACR**
```bash
# Image is stored in ACR with full path:
# myappacr.azurecr.io/myapi:v1.0.0

# ACR stores:
#   - Image layers (deduplicated)
#   - Manifest (image metadata)
#   - Tags (version labels)
```

**Step 3: App Service Pulls from ACR**
```yaml
# App Service configuration:
container:
  registry: myappacr.azurecr.io
  image: myapi:v1.0.0
  
authentication:
  type: ManagedIdentity  # or AdminCredentials
  
# When container starts:
# 1. App Service requests token from Azure AD (using Managed Identity)
# 2. Azure AD validates identity and returns token
# 3. App Service uses token to authenticate with ACR
# 4. ACR validates token and grants access
# 5. App Service pulls image layers
# 6. Container starts with pulled image
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
