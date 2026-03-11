# Azure Application Gateway - Complete Guide

## Table of Contents
1. [Overview](#overview)
2. [Key Features](#key-features)
3. [Components and Architecture](#components-and-architecture)
4. [SKU Options](#sku-options)
5. [When to Use Application Gateway](#when-to-use-application-gateway)
6. [Configuration Options](#configuration-options)
7. [Code Examples](#code-examples)
8. [Advanced Features](#advanced-features)
9. [Best Practices](#best-practices)
10. [Comparison with Other Services](#comparison-with-other-services)
11. [Common Scenarios](#common-scenarios)
12. [Monitoring and Troubleshooting](#monitoring-and-troubleshooting)

---

## 🗺️ Application Gateway Features Mindmap - Complete Overview

```
                                ┌──────────────────────────────────────────┐
                                │   AZURE APPLICATION GATEWAY              │
                                │   "Layer 7 Load Balancer & WAF"          │
                                └───────────────────┬──────────────────────┘
                                                    │
                    ┌───────────────────────────────┼───────────────────────────────┐
                    │                               │                               │
            ┌───────▼────────┐            ┌────────▼────────┐            ┌─────────▼────────┐
            │   CORE ARCH    │            │   ROUTING &     │            │   SECURITY &     │
            │   COMPONENTS   │            │   TRAFFIC       │            │   PROTECTION     │
            └───────┬────────┘            └────────┬────────┘            └─────────┬────────┘
                    │                               │                               │
                    │                               │                               │
                    ▼                               ▼                               ▼

════════════════════════════════════════════════════════════════════════════════════════════

📐 CORE ARCHITECTURE & COMPONENTS
│
├─ Service Characteristics
│  ├─ Layer 7 (Application Layer) Load Balancer
│  ├─ Regional Service (Single Azure Region)
│  ├─ Fully Managed PaaS
│  ├─ Application-Aware Routing
│  ├─ High Availability Built-in
│  └─ Virtual Appliance (deployed in VNet subnet)
│
├─ Frontend Configuration
│  ├─ Public IP Address
│  │  ├─ Standard SKU (Static)
│  │  ├─ Basic SKU (Dynamic) - v1 only
│  │  ├─ IPv4 Support
│  │  └─ DDoS Protection Standard compatible
│  │
│  ├─ Private IP Address
│  │  ├─ Internal-only access
│  │  ├─ Static or Dynamic
│  │  └─ Within VNet address space
│  │
│  └─ Dual Configuration (Both Public & Private)
│
├─ Listeners (Traffic Receivers)
│  ├─ Basic Listener
│  │  ├─ Single site hosting
│  │  ├─ Port + Protocol match
│  │  ├─ One-to-one mapping
│  │  └─ No hostname filtering
│  │
│  ├─ Multi-Site Listener
│  │  ├─ Multiple hostnames/domains
│  │  ├─ Host header matching
│  │  ├─ Wildcard hostname support (*.contoso.com)
│  │  ├─ SNI (Server Name Indication)
│  │  └─ Multiple SSL certificates
│  │
│  ├─ Listener Properties
│  │  ├─ Protocol (HTTP/HTTPS)
│  │  ├─ Port (standard: 80, 443)
│  │  ├─ Frontend IP (public/private)
│  │  ├─ SSL Certificate (HTTPS only)
│  │  └─ Host Name (optional)
│  │
│  └─ Advanced Listener Features
│     ├─ Custom Error Pages
│     ├─ SSL Policy Configuration
│     └─ HTTP/2 Support (default enabled)
│
├─ Backend Pools (Target Servers)
│  ├─ Supported Backend Types
│  │  ├─ Azure VMs (with NIC)
│  │  ├─ VM Scale Sets (VMSS)
│  │  ├─ Azure App Services
│  │  ├─ IP Addresses (internal/external)
│  │  ├─ FQDN (Fully Qualified Domain Names)
│  │  ├─ On-premises servers (via VPN/ExpressRoute)
│  │  └─ Empty pools (allowed for future use)
│  │
│  ├─ Pool Configuration
│  │  ├─ Multiple backends per pool
│  │  ├─ Mix different backend types
│  │  ├─ No port specification (defined in HTTP Settings)
│  │  └─ Dynamic membership changes
│  │
│  └─ Backend Selection Logic
│     ├─ Round-robin (default)
│     ├─ Session affinity (cookie-based)
│     ├─ Health probe status
│     └─ Connection draining support
│
├─ HTTP Settings (Backend Communication)
│  ├─ Protocol Configuration
│  │  ├─ HTTP (port 80 default)
│  │  ├─ HTTPS (port 443 default)
│  │  ├─ Custom ports
│  │  └─ Backend protocol override
│  │
│  ├─ Session Management
│  │  ├─ Cookie-Based Affinity (Enabled/Disabled)
│  │  ├─ Application Gateway Cookie
│  │  ├─ Session stickiness
│  │  └─ Affinity timeout
│  │
│  ├─ Connection Settings
│  │  ├─ Request Timeout (1-86400 seconds)
│  │  ├─ Connection Draining (graceful shutdown)
│  │  ├─ Drain Timeout (1-3600 seconds)
│  │  ├─ Connection Pool
│  │  └─ Keep-Alive settings
│  │
│  ├─ Host Name Override
│  │  ├─ Pick from backend target
│  │  ├─ Override with custom hostname
│  │  ├─ Required for App Service backends
│  │  └─ SNI extension support
│  │
│  ├─ Path Override
│  │  ├─ Modify backend path
│  │  ├─ Add prefix/suffix
│  │  └─ Rewrite URL path
│  │
│  └─ Probe Association
│     ├─ Default probe (automatic)
│     ├─ Custom probe (user-defined)
│     └─ Probe-based health monitoring
│
├─ Health Probes (Backend Monitoring)
│  ├─ Default Probes
│  │  ├─ Automatic creation
│  │  ├─ Protocol from HTTP Settings
│  │  ├─ Path: /
│  │  ├─ Interval: 30 seconds
│  │  ├─ Timeout: 30 seconds
│  │  └─ Unhealthy threshold: 3
│  │
│  ├─ Custom Probes
│  │  ├─ Protocol (HTTP/HTTPS)
│  │  ├─ Custom path (/health, /api/status)
│  │  ├─ Host name (custom or from backend)
│  │  ├─ Interval (1-86400 seconds)
│  │  ├─ Timeout (1-86400 seconds)
│  │  ├─ Unhealthy threshold (1-20)
│  │  └─ Port (custom or from HTTP Settings)
│  │
│  ├─ Health Check Criteria
│  │  ├─ Status Code Matching (200-399 default)
│  │  ├─ Multiple status codes supported
│  │  ├─ Response body matching
│  │  └─ Minimum healthy backends
│  │
│  └─ Probe Results
│     ├─ Healthy (backend available)
│     ├─ Unhealthy (backend unavailable)
│     ├─ Unknown (probe not configured)
│     └─ Draining (connection draining active)
│
├─ Request Routing Rules (Traffic Flow)
│  ├─ Basic Routing Rule
│  │  ├─ One listener → One backend pool
│  │  ├─ Simple one-to-one mapping
│  │  ├─ No path-based logic
│  │  └─ Priority-based execution
│  │
│  ├─ Path-Based Routing Rule
│  │  ├─ URL path maps
│  │  ├─ Multiple path patterns
│  │  ├─ Different backends per path
│  │  ├─ Default backend (catch-all)
│  │  └─ Priority ordering
│  │
│  ├─ Rule Components
│  │  ├─ Listener (traffic receiver)
│  │  ├─ Backend Pool (target servers)
│  │  ├─ HTTP Settings (communication config)
│  │  ├─ URL Path Map (optional)
│  │  ├─ Rewrite Rule Set (optional)
│  │  └─ Redirect Configuration (optional)
│  │
│  └─ Rule Priority
│     ├─ Lower number = higher priority
│     ├─ Range: 1-20000
│     ├─ First matching rule executes
│     └─ No default priority (must specify)
│
└─ Gateway IP Configuration
   ├─ Subnet Association
   │  ├─ Dedicated subnet required
   │  ├─ Minimum /28 subnet size
   │  ├─ /24 recommended for scaling
   │  └─ No other resources in subnet
   │
   ├─ Subnet Requirements
   │  ├─ Must be empty initially
   │  ├─ NSG allowed (with specific rules)
   │  ├─ UDR allowed (with caution)
   │  └─ Service endpoints supported
   │
   └─ IP Addressing
      ├─ Dynamic private IP allocation
      ├─ Internal gateway communication
      └─ Azure infrastructure reserved IPs

════════════════════════════════════════════════════════════════════════════════════════════

🛣️ ROUTING & TRAFFIC MANAGEMENT
│
├─ URL-Based Routing
│  ├─ Path Patterns
│  │  ├─ /api/* → API Backend Pool
│  │  ├─ /images/* → Image Server Pool
│  │  ├─ /video/* → Video Backend Pool
│  │  ├─ /static/* → Static Content Pool
│  │  └─ /* (default/catch-all backend)
│  │
│  ├─ Path Matching Rules
│  │  ├─ Prefix matching
│  │  ├─ Wildcard support (*)
│  │  ├─ Case-sensitive matching
│  │  ├─ Longest match wins
│  │  └─ Query strings ignored
│  │
│  └─ URL Path Map Configuration
│     ├─ Default backend pool (mandatory)
│     ├─ Default HTTP settings (mandatory)
│     ├─ Multiple path rules
│     └─ Rule-specific redirects
│
├─ Multi-Site Hosting
│  ├─ Host-Based Routing
│  │  ├─ www.contoso.com → Backend Pool A
│  │  ├─ www.fabrikam.com → Backend Pool B
│  │  ├─ api.contoso.com → API Pool
│  │  └─ *.contoso.com → Wildcard Pool
│  │
│  ├─ Multi-Site Configuration
│  │  ├─ Host name in listener
│  │  ├─ SNI support (TLS extension)
│  │  ├─ Multiple SSL certificates
│  │  ├─ Per-site routing rules
│  │  └─ Up to 100+ sites per gateway
│  │
│  └─ Hostname Matching
│     ├─ Exact match
│     ├─ Wildcard match (*.domain.com)
│     ├─ Case-insensitive
│     └─ Host header validation
│
├─ Redirection (Traffic Forwarding)
│  ├─ HTTP to HTTPS Redirect
│  │  ├─ Permanent (301)
│  │  ├─ Temporary (302, 307)
│  │  ├─ Path preserved
│  │  └─ Query string preserved
│  │
│  ├─ Redirection Types
│  │  ├─ Protocol redirect (HTTP→HTTPS)
│  │  ├─ URL redirect (path change)
│  │  ├─ Site redirect (domain change)
│  │  └─ External URL redirect
│  │
│  ├─ Redirect Configuration
│  │  ├─ Target listener (internal)
│  │  ├─ Target URL (external)
│  │  ├─ Include path (yes/no)
│  │  ├─ Include query string (yes/no)
│  │  └─ Redirect type (permanent/temporary)
│  │
│  └─ Use Cases
│     ├─ Force HTTPS
│     ├─ Domain migration
│     ├─ Maintenance pages
│     └─ Legacy URL support
│
├─ Header Rewriting
│  ├─ Request Header Rewrite
│  │  ├─ Add custom headers
│  │  ├─ Modify existing headers
│  │  ├─ Remove headers
│  │  ├─ X-Forwarded-For preservation
│  │  ├─ Client IP injection
│  │  └─ Correlation ID addition
│  │
│  ├─ Response Header Rewrite
│  │  ├─ Add security headers
│  │  ├─ Remove server info headers
│  │  ├─ HSTS (Strict-Transport-Security)
│  │  ├─ X-Frame-Options
│  │  ├─ X-Content-Type-Options
│  │  └─ Custom application headers
│  │
│  ├─ Rewrite Conditions
│  │  ├─ HTTP header comparison
│  │  ├─ Server variable check
│  │  ├─ Pattern matching (regex)
│  │  └─ Multiple conditions (AND/OR)
│  │
│  └─ Rewrite Rule Sets
│     ├─ Multiple rules per set
│     ├─ Sequential execution
│     ├─ Rule priority (sequence)
│     └─ Reusable across rules
│
├─ URL Rewriting
│  ├─ Path Modification
│  │  ├─ Rewrite backend path
│  │  ├─ Add/remove prefix
│  │  ├─ Path parameter extraction
│  │  └─ Dynamic path construction
│  │
│  ├─ Query String Modification
│  │  ├─ Add query parameters
│  │  ├─ Remove parameters
│  │  ├─ Modify parameter values
│  │  └─ Preserve/override
│  │
│  └─ Rewrite Scenarios
│     ├─ API versioning (v1 → v2)
│     ├─ Backend compatibility
│     ├─ URL normalization
│     └─ Path translation
│
└─ Load Balancing Algorithm
   ├─ Round-Robin (default)
   │  ├─ Equal distribution
   │  ├─ Sequential selection
   │  └─ No weight consideration
   │
   ├─ Session Affinity Override
   │  ├─ Cookie-based stickiness
   │  ├─ Same backend per session
   │  └─ Affinity timeout handling
   │
   └─ Health-Based Selection
      ├─ Only healthy backends
      ├─ Automatic failover
      └─ Connection draining support

════════════════════════════════════════════════════════════════════════════════════════════

🔐 SECURITY & PROTECTION
│
├─ Web Application Firewall (WAF)
│  ├─ WAF Capabilities
│  │  ├─ OWASP Top 10 Protection
│  │  ├─ Bot Protection
│  │  ├─ DDoS Mitigation (Layer 7)
│  │  ├─ SQL Injection prevention
│  │  ├─ Cross-Site Scripting (XSS) prevention
│  │  ├─ Remote File Inclusion (RFI) protection
│  │  ├─ Request size limits
│  │  └─ Geo-filtering
│  │
│  ├─ WAF Modes
│  │  ├─ Detection Mode
│  │  │  ├─ Monitor only
│  │  │  ├─ Log violations
│  │  │  ├─ No blocking
│  │  │  └─ Testing/tuning phase
│  │  │
│  │  └─ Prevention Mode
│  │     ├─ Block malicious requests
│  │     ├─ Return 403 Forbidden
│  │     ├─ Log blocked requests
│  │     └─ Production mode
│  │
│  ├─ WAF Rule Sets
│  │  ├─ Managed Rule Sets
│  │  │  ├─ OWASP Core Rule Set (CRS)
│  │  │  ├─ CRS 3.2 (latest)
│  │  │  ├─ CRS 3.1
│  │  │  ├─ CRS 3.0
│  │  │  ├─ Microsoft Bot Manager
│  │  │  └─ Automatic updates
│  │  │
│  │  ├─ Custom Rules
│  │  │  ├─ IP allow/deny lists
│  │  │  ├─ Geo-blocking
│  │  │  ├─ Rate limiting per IP
│  │  │  ├─ Custom pattern matching
│  │  │  ├─ Priority-based execution
│  │  │  └─ Allow/Block/Log actions
│  │  │
│  │  └─ Rule Exclusions
│  │     ├─ Disable specific rules
│  │     ├─ Request header exclusions
│  │     ├─ Request body exclusions
│  │     ├─ Cookie exclusions
│  │     └─ False positive handling
│  │
│  ├─ WAF Policy
│  │  ├─ Policy-based configuration (v2)
│  │  ├─ Reusable across gateways
│  │  ├─ Per-site policies
│  │  ├─ Per-URI policies
│  │  ├─ Policy settings
│  │  │  ├─ Request body inspection
│  │  │  ├─ Max request body size (128 KB)
│  │  │  ├─ File upload limit (4 GB)
│  │  │  └─ Request body check
│  │  │
│  │  └─ Policy Association
│  │     ├─ Global (entire gateway)
│  │     ├─ Per-listener
│  │     ├─ Per-path rule
│  │     └─ Inheritance hierarchy
│  │
│  └─ WAF Logging & Monitoring
│     ├─ Firewall logs
│     ├─ Rule match details
│     ├─ Blocked request logs
│     ├─ Anomaly scores
│     └─ Integration with Azure Monitor
│
├─ SSL/TLS Configuration
│  ├─ SSL Termination (Offloading)
│  │  ├─ Decrypt at gateway
│  │  ├─ HTTP to backend
│  │  ├─ Certificate at gateway only
│  │  ├─ Reduced backend CPU load
│  │  └─ Centralized cert management
│  │
│  ├─ End-to-End SSL
│  │  ├─ HTTPS to gateway
│  │  ├─ HTTPS to backend
│  │  ├─ Certificate at both ends
│  │  ├─ Trusted root certificates
│  │  └─ Maximum security
│  │
│  ├─ SSL Bridging
│  │  ├─ Decrypt then re-encrypt
│  │  ├─ Inspect traffic at gateway
│  │  ├─ Different certs (frontend/backend)
│  │  └─ WAF inspection possible
│  │
│  ├─ Certificate Management
│  │  ├─ PFX/PEM format support
│  │  ├─ Azure Key Vault integration
│  │  │  ├─ Managed Identity authentication
│  │  │  ├─ Automatic certificate rotation
│  │  │  ├─ Secret references
│  │  │  └─ Centralized storage
│  │  │
│  │  ├─ Self-Signed Certificates (testing)
│  │  ├─ CA-Signed Certificates (production)
│  │  ├─ Wildcard Certificates
│  │  ├─ SAN (Subject Alternative Name) Certs
│  │  └─ Certificate expiration monitoring
│  │
│  ├─ SSL Policy Configuration
│  │  ├─ Predefined Policies
│  │  │  ├─ AppGwSslPolicy20150501 (legacy)
│  │  │  ├─ AppGwSslPolicy20170401
│  │  │  ├─ AppGwSslPolicy20170401S (strict)
│  │  │  ├─ AppGwSslPolicy20220101 (latest)
│  │  │  └─ AppGwSslPolicy20220101S (strictest)
│  │  │
│  │  ├─ Custom SSL Policy
│  │  │  ├─ TLS version (1.0, 1.1, 1.2, 1.3)
│  │  │  ├─ Cipher suites selection
│  │  │  ├─ Cipher order enforcement
│  │  │  └─ Security vs compatibility balance
│  │  │
│  │  └─ Recommended Settings
│  │     ├─ TLS 1.2+ only
│  │     ├─ Strong cipher suites only
│  │     ├─ Disable weak ciphers
│  │     └─ Perfect Forward Secrecy (PFS)
│  │
│  ├─ Mutual TLS (mTLS)
│  │  ├─ Client certificate authentication
│  │  ├─ Trusted root CA certificates
│  │  ├─ Certificate validation
│  │  ├─ Certificate revocation check
│  │  └─ SSL profile configuration
│  │
│  └─ SSL/TLS Best Practices
│     ├─ Use TLS 1.2 or higher
│     ├─ Disable SSL 3.0, TLS 1.0, TLS 1.1
│     ├─ Strong cipher suites only
│     ├─ Certificate auto-renewal
│     └─ Regular security audits
│
├─ Network Security
│  ├─ Network Security Groups (NSG)
│  │  ├─ Allowed on App Gateway subnet
│  │  ├─ Required inbound rules:
│  │  │  ├─ Internet → 65200-65535 (management)
│  │  │  ├─ Internet → 80, 443 (application traffic)
│  │  │  ├─ GatewayManager service tag
│  │  │  └─ AzureLoadBalancer service tag
│  │  │
│  │  ├─ Outbound rules:
│  │  │  ├─ Backend subnet access
│  │  │  ├─ Internet access (for external backends)
│  │  │  └─ Azure service access
│  │  │
│  │  └─ NSG Best Practices
│  │     ├─ Allow required management ports
│  │     ├─ Restrict source IPs if possible
│  │     ├─ Document all rules
│  │     └─ Regular rule review
│  │
│  ├─ User-Defined Routes (UDR)
│  │  ├─ Supported with limitations
│  │  ├─ Don't override 0.0.0.0/0 to Internet
│  │  ├─ Preserve Azure infrastructure routes
│  │  ├─ Network Virtual Appliance (NVA) considerations
│  │  └─ Test thoroughly before production
│  │
│  ├─ Private Link Support
│  │  ├─ Private connectivity to App Gateway
│  │  ├─ Private endpoints from other VNets
│  │  ├─ No public IP required
│  │  ├─ Cross-region private connectivity
│  │  └─ On-premises access via ExpressRoute
│  │
│  └─ DDoS Protection
│     ├─ Basic (always enabled, free)
│     ├─ Standard (enhanced, additional cost)
│     ├─ Layer 3/4 protection
│     ├─ Traffic monitoring
│     └─ Attack mitigation
│
├─ Authentication & Authorization
│  ├─ Client Certificate Authentication
│  │  ├─ mTLS support
│  │  ├─ Certificate validation
│  │  └─ Trusted CA configuration
│  │
│  ├─ Backend Authentication
│  │  ├─ Backend certificates
│  │  ├─ Trusted root certificates
│  │  └─ Certificate whitelist
│  │
│  └─ Header-Based Authentication
│     ├─ Custom headers
│     ├─ Header rewriting for auth tokens
│     └─ Integration with Azure AD
│
└─ Compliance & Security Features
   ├─ PCI DSS Compliance
   ├─ HIPAA Compliance
   ├─ SOC 1/2/3 Compliance
   ├─ ISO 27001 Certified
   ├─ Encryption at rest
   └─ Encryption in transit

════════════════════════════════════════════════════════════════════════════════════════════

⚡ PERFORMANCE & SCALABILITY
│
├─ Autoscaling (v2 SKU)
│  ├─ Capacity Units (CU)
│  │  ├─ Compute Units (CPU/processing)
│  │  ├─ Persistent Connections (2,500 per CU)
│  │  ├─ Throughput (2.22 Mbps per CU)
│  │  └─ Highest of three determines CU
│  │
│  ├─ Autoscale Configuration
│  │  ├─ Minimum Capacity (0-100 instances)
│  │  ├─ Maximum Capacity (2-125 instances)
│  │  ├─ Automatic scaling based on load
│  │  ├─ Scale-out time: ~6-7 minutes
│  │  └─ Scale-in time: ~30 minutes
│  │
│  ├─ Fixed Capacity (v2)
│  │  ├─ Set specific instance count
│  │  ├─ No autoscaling
│  │  ├─ Predictable costs
│  │  └─ Manual scaling required
│  │
│  └─ v1 SKU Scaling (Legacy)
│     ├─ Manual instance count (1-32)
│     ├─ Small/Medium/Large sizes
│     ├─ No autoscaling
│     └─ Downtime during scaling
│
├─ Protocol Support
│  ├─ HTTP/1.1
│  │  ├─ Standard web traffic
│  │  ├─ Keep-alive support
│  │  └─ Pipeline support
│  │
│  ├─ HTTP/2
│  │  ├─ Enabled by default (v2)
│  │  ├─ Better performance
│  │  ├─ Multiplexing
│  │  ├─ Header compression
│  │  └─ Server push (not supported)
│  │
│  ├─ WebSocket
│  │  ├─ Native support
│  │  ├─ Bidirectional communication
│  │  ├─ Real-time applications
│  │  └─ Long-lived connections
│  │
│  └─ TCP/UDP
│     └─ Not supported (use Azure Load Balancer)
│
├─ Session Management
│  ├─ Cookie-Based Affinity
│  │  ├─ Application Gateway cookie (ApplicationGatewayAffinity)
│  │  ├─ Sticky sessions
│  │  ├─ Same backend per cookie
│  │  ├─ Backend-level affinity
│  │  └─ Configurable per HTTP Setting
│  │
│  ├─ Connection Draining
│  │  ├─ Graceful backend removal
│  │  ├─ Complete existing connections
│  │  ├─ No new connections to draining backend
│  │  ├─ Drain timeout (1-3600 seconds)
│  │  └─ Health probe shows "Draining" status
│  │
│  └─ Session Timeout
│     ├─ Request timeout setting
│     ├─ Idle connection timeout
│     └─ Keep-alive management
│
├─ Connection Optimization
│  ├─ Connection Pooling
│  │  ├─ Reuse backend connections
│  │  ├─ Reduced connection overhead
│  │  ├─ Improved throughput
│  │  └─ Automatic management
│  │
│  ├─ Keep-Alive
│  │  ├─ TCP keep-alive
│  │  ├─ HTTP keep-alive
│  │  ├─ Reduced latency
│  │  └─ Connection reuse
│  │
│  └─ Connection Limits
│     ├─ Frontend: 20,000 connections per instance
│     ├─ Backend: Determined by backend capacity
│     └─ Capacity unit calculation
│
├─ Performance Features
│  ├─ Response Caching
│  │  └─ Not natively supported (use Azure CDN)
│  │
│  ├─ Compression
│  │  └─ Not natively supported (backend handles it)
│  │
│  ├─ Static Content Acceleration
│  │  └─ Consider Azure CDN for static content
│  │
│  └─ Request Buffering
│     ├─ Full request buffering at gateway
│     ├─ Protects backend from slow clients
│     └─ Improves backend performance
│
└─ Throughput & Capacity
   ├─ Standard_v2 / WAF_v2 Performance
   │  ├─ ~125 instances max
   │  ├─ ~2.22 Mbps per capacity unit
   │  ├─ ~10 Gbps+ throughput potential
   │  └─ Sub-second latency
   │
   ├─ v1 Performance (Legacy)
   │  ├─ Small: ~200 Mbps
   │  ├─ Medium: ~500 Mbps
   │  ├─ Large: ~1250 Mbps
   │  └─ WAF reduces throughput ~30%
   │
   └─ Performance Factors
      ├─ SSL/TLS overhead
      ├─ WAF processing
      ├─ Rule complexity
      ├─ Backend response time
      └─ Network latency

════════════════════════════════════════════════════════════════════════════════════════════

🏗️ HIGH AVAILABILITY & RESILIENCE
│
├─ Zone Redundancy (v2 SKU)
│  ├─ Availability Zones
│  │  ├─ Deploy across zones 1, 2, 3
│  │  ├─ Automatic instance distribution
│  │  ├─ No manual configuration needed
│  │  └─ Available in zone-supported regions
│  │
│  ├─ Zone Redundancy Benefits
│  │  ├─ 99.99% SLA (vs 99.95% single zone)
│  │  ├─ Automatic failover
│  │  ├─ No downtime during zone failure
│  │  ├─ No data loss
│  │  └─ Transparent to applications
│  │
│  └─ Zone Configuration
│     ├─ Specify zones during creation
│     ├─ Cannot change after deployment
│     ├─ All instances distributed equally
│     └─ Public IP must be zone-redundant
│
├─ Instance Distribution
│  ├─ Multiple Instances
│  │  ├─ Minimum 2 instances recommended
│  │  ├─ Active-active configuration
│  │  ├─ Load distributed across instances
│  │  └─ No single point of failure
│  │
│  ├─ Instance Health Monitoring
│  │  ├─ Azure monitors instance health
│  │  ├─ Automatic instance replacement
│  │  ├─ No user intervention needed
│  │  └─ Continuous availability
│  │
│  └─ Scaling Events
│     ├─ No downtime during scale out
│     ├─ No downtime during scale in
│     ├─ Connection draining during scale in
│     └─ Graceful instance addition/removal
│
├─ Backend Redundancy
│  ├─ Multiple Backend Servers
│  │  ├─ At least 2 backends per pool
│  │  ├─ Distribute across availability zones
│  │  ├─ Different fault domains
│  │  └─ Load distribution across healthy backends
│  │
│  ├─ Health-Based Routing
│  │  ├─ Only route to healthy backends
│  │  ├─ Automatic failover to healthy servers
│  │  ├─ Health probe monitoring
│  │  └─ No manual intervention
│  │
│  ├─ Backend Pool Strategies
│  │  ├─ VM Scale Sets (auto-scaling backends)
│  │  ├─ Availability Sets (fault domain separation)
│  │  ├─ Zone-distributed VMs
│  │  └─ Multi-region backends (with Front Door)
│  │
│  └─ Graceful Degradation
│     ├─ Connection draining
│     ├─ No abrupt disconnections
│     ├─ Complete in-flight requests
│     └─ Configurable drain timeout
│
├─ Disaster Recovery
│  ├─ Regional Redundancy
│  │  ├─ Deploy in multiple regions
│  │  ├─ Use Azure Traffic Manager or Front Door
│  │  ├─ Active-active setup
│  │  └─ DNS-based failover
│  │
│  ├─ Backup & Configuration
│  │  ├─ Export configuration (ARM template)
│  │  ├─ Script-based deployment
│  │  ├─ Infrastructure as Code (Bicep/Terraform)
│  │  └─ Version control configuration
│  │
│  └─ Recovery Objectives
│     ├─ RTO (Recovery Time Objective)
│     ├─ RPO (Recovery Point Objective)
│     ├─ Automated failover
│     └─ Testing DR procedures
│
├─ SLA & Uptime
│  ├─ v2 SKU (Zone Redundant)
│  │  ├─ 99.99% SLA (multi-zone)
│  │  ├─ ~4 minutes downtime/month max
│  │  └─ Requires 2+ instances across zones
│  │
│  ├─ v2 SKU (Single Zone)
│  │  ├─ 99.95% SLA
│  │  ├─ ~22 minutes downtime/month max
│  │  └─ Requires 2+ instances
│  │
│  ├─ v1 SKU
│  │  ├─ 99.95% SLA
│  │  ├─ Requires 2+ instances
│  │  └─ No zone redundancy
│  │
│  └─ SLA Requirements
│     ├─ Multiple instances mandatory
│     ├─ Same update domain
│     ├─ Same fault domain protection
│     └─ Azure-managed uptime
│
└─ Update & Maintenance
   ├─ Managed Updates
   │  ├─ Azure-managed patching
   │  ├─ Zero-downtime updates
   │  ├─ Rolling update strategy
   │  └─ No user action required
   │
   ├─ Planned Maintenance
   │  ├─ Notification in advance
   │  ├─ Update domains utilized
   │  ├─ No service interruption
   │  └─ Configuration changes applied
   │
   └─ Unplanned Maintenance
      ├─ Automatic failover
      ├─ Instance replacement
      ├─ Health monitoring
      └─ Self-healing infrastructure

════════════════════════════════════════════════════════════════════════════════════════════

📊 MONITORING & DIAGNOSTICS
│
├─ Metrics (Azure Monitor)
│  ├─ Health Metrics
│  │  ├─ Healthy Host Count (per backend pool)
│  │  ├─ Unhealthy Host Count (critical alert)
│  │  ├─ Total healthy/unhealthy ratio
│  │  └─ Backend status over time
│  │
│  ├─ Traffic Metrics
│  │  ├─ Total Requests
│  │  ├─ Requests per second (RPS)
│  │  ├─ Failed Requests
│  │  ├─ Current Connections
│  │  ├─ New Connections per second
│  │  └─ Connection state distribution
│  │
│  ├─ Performance Metrics
│  │  ├─ Backend Response Time (latency)
│  │  ├─ Application Gateway Total Time
│  │  ├─ First Byte Response Time
│  │  ├─ Last Byte Response Time
│  │  └─ Response time percentiles (95th, 99th)
│  │
│  ├─ HTTP Status Metrics
│  │  ├─ HTTP 2xx responses (success)
│  │  ├─ HTTP 3xx responses (redirects)
│  │  ├─ HTTP 4xx responses (client errors)
│  │  ├─ HTTP 5xx responses (server errors)
│  │  └─ Status code distribution
│  │
│  ├─ Capacity Metrics (v2)
│  │  ├─ Current Capacity Units
│  │  ├─ Compute Units consumed
│  │  ├─ Throughput (bytes/sec)
│  │  ├─ Instance Count
│  │  └─ Estimated Billed Capacity Units
│  │
│  ├─ SSL/TLS Metrics
│  │  ├─ Client TLS Protocol version
│  │  ├─ Backend TLS Protocol version
│  │  ├─ SSL/TLS handshake time
│  │  └─ Certificate expiration status
│  │
│  └─ Throughput Metrics
│     ├─ Bytes Sent (outbound)
│     ├─ Bytes Received (inbound)
│     ├─ Throughput (Mbps)
│     └─ Bandwidth utilization
│
├─ Diagnostic Logs
│  ├─ Access Logs
│  │  ├─ Client IP address
│  │  ├─ Request timestamp
│  │  ├─ HTTP method & URI
│  │  ├─ HTTP status code
│  │  ├─ Response size
│  │  ├─ User-Agent
│  │  ├─ Time taken (total)
│  │  ├─ Backend server contacted
│  │  ├─ SSL cipher used
│  │  └─ Request/response headers
│  │
│  ├─ Performance Logs
│  │  ├─ Gateway instance ID
│  │  ├─ Healthy/unhealthy host count
│  │  ├─ Request count per backend
│  │  ├─ Average response time
│  │  ├─ Failed request count
│  │  └─ Throughput statistics
│  │
│  ├─ Firewall Logs (WAF)
│  │  ├─ Matched rule ID
│  │  ├─ Rule set version
│  │  ├─ Action taken (allow/block/log)
│  │  ├─ Anomaly score
│  │  ├─ Request details
│  │  ├─ Client IP & location
│  │  └─ Attack category
│  │
│  └─ Activity Logs
│     ├─ Configuration changes
│     ├─ Resource operations
│     ├─ Scaling events
│     ├─ Administrative actions
│     └─ RBAC changes
│
├─ Log Destinations
│  ├─ Log Analytics Workspace
│  │  ├─ Advanced querying (KQL)
│  │  ├─ Long-term retention
│  │  ├─ Visualization & dashboards
│  │  ├─ Cross-resource correlation
│  │  └─ Alert integration
│  │
│  ├─ Storage Account
│  │  ├─ Long-term archival
│  │  ├─ Compliance requirements
│  │  ├─ Cost-effective storage
│  │  └─ Raw log preservation
│  │
│  ├─ Event Hub
│  │  ├─ Real-time streaming
│  │  ├─ SIEM integration
│  │  ├─ Third-party tools
│  │  └─ Custom processing
│  │
│  └─ Partner Solutions
│     ├─ Splunk
│     ├─ Datadog
│     ├─ Sumo Logic
│     └─ Other monitoring platforms
│
├─ Alerts & Notifications
│  ├─ Metric-Based Alerts
│  │  ├─ Unhealthy host count > 0
│  │  ├─ Failed requests threshold
│  │  ├─ High response time
│  │  ├─ Capacity units near max
│  │  ├─ HTTP 5xx errors spike
│  │  └─ Custom threshold alerts
│  │
│  ├─ Log-Based Alerts
│  │  ├─ WAF blocks exceeding limit
│  │  ├─ Specific error patterns
│  │  ├─ Configuration changes
│  │  └─ Security events
│  │
│  ├─ Action Groups
│  │  ├─ Email notifications
│  │  ├─ SMS alerts
│  │  ├─ Webhook calls
│  │  ├─ Logic Apps integration
│  │  ├─ Azure Functions trigger
│  │  ├─ ITSM integration
│  │  └─ Runbook automation
│  │
│  └─ Smart Alerts
│     ├─ Anomaly detection
│     ├─ Machine learning-based
│     ├─ Adaptive thresholds
│     └─ Reduced alert noise
│
├─ Troubleshooting Tools
│  ├─ Backend Health View
│  │  ├─ Real-time backend status
│  │  ├─ Per-instance health
│  │  ├─ Probe details
│  │  └─ Error messages
│  │
│  ├─ Connection Troubleshoot
│  │  ├─ Network Watcher integration
│  │  ├─ Connectivity tests
│  │  ├─ Hop-by-hop analysis
│  │  └─ NSG rule verification
│  │
│  ├─ Resource Health
│  │  ├─ Platform health status
│  │  ├─ Historical health view
│  │  ├─ Planned maintenance info
│  │  └─ Downtime root cause
│  │
│  └─ Diagnostic Settings
│     ├─ Enable all log categories
│     ├─ Send to Log Analytics
│     ├─ Configure retention
│     └─ Verify log flow
│
└─ Integration & Visualization
   ├─ Azure Monitor Workbooks
   │  ├─ Pre-built workbooks
   │  ├─ Custom visualizations
   │  ├─ Interactive dashboards
   │  └─ Parameterized queries
   │
   ├─ Application Insights
   │  ├─ E2E transaction tracking
   │  ├─ Dependency mapping
   │  ├─ Failure analysis
   │  └─ User behavior analytics
   │
   ├─ Azure Dashboards
   │  ├─ Real-time metrics
   │  ├─ Multiple resource views
   │  ├─ Shared team dashboards
   │  └─ Custom tile layouts
   │
   └─ Power BI
      ├─ Advanced analytics
      ├─ Custom reports
      ├─ Business intelligence
      └─ Executive dashboards

════════════════════════════════════════════════════════════════════════════════════════════

🌐 CONNECTIVITY & INTEGRATION
│
├─ Virtual Network Integration
│  ├─ Subnet Requirements
│  │  ├─ Dedicated subnet mandatory
│  │  ├─ Minimum /28 (16 IPs)
│  │  ├─ Recommended /24 (256 IPs) for scaling
│  │  ├─ Cannot share with other resources
│  │  ├─ Must be empty during initial deployment
│  │  └─ Address space within VNet CIDR
│  │
│  ├─ Subnet Configuration
│  │  ├─ NSG support (with specific rules)
│  │  ├─ UDR support (with limitations)
│  │  ├─ Service endpoints allowed
│  │  ├─ No delegation required
│  │  └─ No private endpoints in same subnet
│  │
│  ├─ VNet Peering
│  │  ├─ Access backends in peered VNets
│  │  ├─ Global VNet peering supported
│  │  ├─ Requires proper routing
│  │  └─ NSG rules must permit traffic
│  │
│  └─ VNet Service Endpoints
│     ├─ Direct Azure service access
│     ├─ Microsoft.Storage
│     ├─ Microsoft.Sql
│     ├─ Microsoft.KeyVault
│     └─ Improved security & performance
│
├─ Hybrid Connectivity
│  ├─ VPN Gateway
│  │  ├─ Site-to-Site (S2S) VPN
│  │  ├─ Access on-premises backends
│  │  ├─ Encrypted tunnel
│  │  ├─ Routing configuration
│  │  └─ Gateway subnet required
│  │
│  ├─ ExpressRoute
│  │  ├─ Private connection to Azure
│  │  ├─ Higher bandwidth
│  │  ├─ Lower latency
│  │  ├─ More reliable
│  │  └─ Dedicated circuit
│  │
│  ├─ On-Premises Backend Routing
│  │  ├─ Backend pool with on-prem IPs
│  │  ├─ Custom DNS resolution
│  │  ├─ Health probe considerations
│  │  └─ Firewall rules required
│  │
│  └─ Hybrid Scenarios
│     ├─ Cloud + on-premises backends
│     ├─ Gradual migration
│     ├─ Disaster recovery
│     └─ Data residency requirements
│
├─ Multi-Region & Global
│  ├─ Regional Deployment
│  │  ├─ Single Azure region per gateway
│  │  ├─ Multiple gateways for multi-region
│  │  ├─ Independent configuration
│  │  └─ Region-specific backends
│  │
│  ├─ Azure Front Door Integration
│  │  ├─ Global load balancing
│  │  ├─ Front Door → App Gateway per region
│  │  ├─ CDN capabilities
│  │  ├─ Global WAF
│  │  └─ Cross-region failover
│  │
│  ├─ Traffic Manager Integration
│  │  ├─ DNS-based routing
│  │  ├─ Performance-based routing
│  │  ├─ Geographic routing
│  │  ├─ Priority-based failover
│  │  └─ Multi-region DR
│  │
│  └─ Private Link Cross-Region
│     ├─ Private endpoints in remote VNets
│     ├─ Global VNet peering
│     ├─ ExpressRoute Global Reach
│     └─ Secured cross-region access
│
├─ Azure Service Integration
│  ├─ Backend Services
│  │  ├─ Azure Virtual Machines
│  │  ├─ VM Scale Sets (VMSS)
│  │  ├─ Azure App Service
│  │  ├─ Azure Kubernetes Service (AKS)
│  │  ├─ Azure Container Instances
│  │  ├─ Azure Spring Apps
│  │  ├─ Azure API Management
│  │  └─ Azure Functions
│  │
│  ├─ Security Services
│  │  ├─ Azure Key Vault (certificates)
│  │  ├─ Azure Active Directory (authentication)
│  │  ├─ Microsoft Entra ID
│  │  ├─ Azure DDoS Protection
│  │  └─ Azure Firewall (network security)
│  │
│  ├─ Monitoring Services
│  │  ├─ Azure Monitor
│  │  ├─ Application Insights
│  │  ├─ Log Analytics
│  │  ├─ Network Watcher
│  │  └─ Azure Sentinel (SIEM)
│  │
│  └─ DevOps Services
│     ├─ Azure DevOps (CI/CD)
│     ├─ GitHub Actions
│     ├─ ARM Templates
│     ├─ Bicep
│     └─ Terraform
│
├─ DNS Configuration
│  ├─ Public DNS
│  │  ├─ A record to public IP
│  │  ├─ CNAME to gateway FQDN
│  │  ├─ Multiple DNS records for multi-site
│  │  └─ Azure DNS or external DNS
│  │
│  ├─ Private DNS
│  │  ├─ Azure Private DNS Zones
│  │  ├─ Internal name resolution
│  │  ├─ VNet-linked DNS zones
│  │  └─ Custom DNS servers
│  │
│  └─ DNS Management
│     ├─ TTL configuration
│     ├─ Health check integration
│     ├─ Failover DNS records
│     └─ DNSSEC support
│
└─ API & Management
   ├─ Azure Portal
   │  ├─ GUI-based management
   │  ├─ Configuration wizards
   │  ├─ Monitoring dashboards
   │  └─ Backend health view
   │
   ├─ Azure CLI
   │  ├─ Command-line automation
   │  ├─ Scripting support
   │  ├─ Cross-platform
   │  └─ CI/CD integration
   │
   ├─ PowerShell
   │  ├─ Automation scripts
   │  ├─ Bulk operations
   │  ├─ Windows integration
   │  └─ Azure Automation
   │
   ├─ REST API
   │  ├─ Programmatic access
   │  ├─ Custom tooling
   │  ├─ Integration scenarios
   │  └─ Webhook triggers
   │
   └─ SDKs
      ├─ .NET SDK
      ├─ Python SDK
      ├─ Java SDK
      ├─ Node.js SDK
      └─ Go SDK

════════════════════════════════════════════════════════════════════════════════════════════

💰 COST & SKU DETAILS
│
├─ SKU Comparison Matrix
│  ├─ v1 SKU (Legacy - Not Recommended)
│  │  ├─ Standard_Small
│  │  │  ├─ 2 instances
│  │  │  ├─ ~200 Mbps throughput
│  │  │  ├─ No autoscaling
│  │  │  └─ No zone redundancy
│  │  │
│  │  ├─ Standard_Medium
│  │  │  ├─ 2 instances
│  │  │  ├─ ~500 Mbps throughput
│  │  │  ├─ No autoscaling
│  │  │  └─ No zone redundancy
│  │  │
│  │  ├─ Standard_Large
│  │  │  ├─ 2 instances
│  │  │  ├─ ~1250 Mbps throughput
│  │  │  ├─ No autoscaling
│  │  │  └─ No zone redundancy
│  │  │
│  │  ├─ WAF_Medium
│  │  │  ├─ WAF protection included
│  │  │  ├─ ~500 Mbps throughput (reduced)
│  │  │  ├─ OWASP rule sets
│  │  │  └─ No autoscaling
│  │  │
│  │  └─ WAF_Large
│  │     ├─ WAF protection included
│  │     ├─ ~1250 Mbps throughput (reduced)
│  │     ├─ OWASP rule sets
│  │     └─ No autoscaling
│  │
│  └─ v2 SKU (Recommended)
│     ├─ Standard_v2
│     │  ├─ Autoscaling (0-125 instances)
│     │  ├─ Zone redundancy
│     │  ├─ Static VIP
│     │  ├─ Header rewriting
│     │  ├─ HTTP/2 support
│     │  ├─ Key Vault integration
│     │  ├─ Better performance
│     │  ├─ Capacity Units-based pricing
│     │  └─ No WAF (add separately)
│     │
│     └─ WAF_v2
│        ├─ All Standard_v2 features
│        ├─ WAF protection included
│        ├─ OWASP CRS 3.2
│        ├─ Bot protection
│        ├─ Custom rules
│        ├─ Per-site WAF policies
│        ├─ Managed rule sets
│        └─ Higher pricing
│
├─ Pricing Components
│  ├─ Fixed Hourly Cost
│  │  ├─ Charged per hour (always running)
│  │  ├─ Varies by SKU & region
│  │  ├─ ~$0.25/hour (Standard_v2, US regions)
│  │  ├─ Includes first 5 Capacity Units
│  │  └─ ~$143/month minimum (v2)
│  │
│  ├─ Capacity Units Cost (v2)
│  │  ├─ Beyond first 5 CU included
│  │  ├─ ~$0.008 per CU per hour
│  │  ├─ Based on highest of:
│  │  │  ├─ Compute Units (CPU)
│  │  │  ├─ Persistent Connections / 2,500
│  │  │  └─ Throughput (Mbps) / 2.22
│  │  └─ Autoscaling charges more during peaks
│  │
│  ├─ Data Processing (v1 only)
│  │  ├─ Charged per GB processed
│  │  ├─ ~$0.008 per GB
│  │  ├─ Inbound + outbound data
│  │  └─ Not applicable to v2
│  │
│  ├─ WAF Additional Cost
│  │  ├─ WAF_v2 SKU higher base rate
│  │  ├─ ~$0.36/hour (vs $0.25)
│  │  ├─ Policy-based pricing
│  │  └─ Rule evaluation cost
│  │
│  └─ Outbound Data Transfer
│     ├─ Standard Azure egress rates
│     ├─ First 5 GB/month free
│     ├─ ~$0.087/GB (5-10 TB)
│     └─ Reduced rates for higher volume
│
├─ Cost Optimization Strategies
│  ├─ Right-Sizing
│  │  ├─ Monitor capacity unit usage
│  │  ├─ Adjust min/max autoscale settings
│  │  ├─ Remove unused resources
│  │  └─ Consolidate applications
│  │
│  ├─ Reserved Capacity
│  │  ├─ 1-year commitment: ~30% savings
│  │  ├─ 3-year commitment: ~50% savings
│  │  ├─ Predictable workloads
│  │  └─ Pay upfront or monthly
│  │
│  ├─ Multi-Site Hosting
│  │  ├─ Host multiple websites per gateway
│  │  ├─ Share fixed costs
│  │  ├─ Path-based routing efficiency
│  │  └─ Reduce gateway sprawl
│  │
│  ├─ Autoscaling Configuration
│  │  ├─ Set realistic min capacity
│  │  ├─ Limit max capacity appropriately
│  │  ├─ Scale based on actual usage patterns
│  │  └─ Avoid over-provisioning
│  │
│  ├─ Azure Hybrid Benefit
│  │  └─ Not applicable (PaaS service)
│  │
│  └─ Dev/Test Optimization
│     ├─ Use smaller instances for dev/test
│     ├─ Stop when not in use (not possible)
│     ├─ Shared dev gateway for multiple teams
│     └─ Lower min capacity for non-prod
│
├─ Cost Monitoring
│  ├─ Azure Cost Management
│  │  ├─ Track spending trends
│  │  ├─ Set budget alerts
│  │  ├─ Cost analysis reports
│  │  └─ Forecast future costs
│  │
│  ├─ Capacity Unit Monitoring
│  │  ├─ Track CU usage metric
│  │  ├─ Identify cost drivers
│  │  ├─ Correlate with traffic patterns
│  │  └─ Optimize configurations
│  │
│  └─ Tags for Cost Allocation
│     ├─ Department tags
│     ├─ Project tags
│     ├─ Environment tags
│     └─ Cost center tags
│
└─ Pricing Example (Standard_v2)
   ├─ Base: ~$180/month (720 hours × $0.25)
   ├─ Includes: First 5 CU
   ├─ Additional CU: $0.008/CU/hour
   ├─ Example Load:
   │  ├─ 10 Capacity Units average
   │  ├─ Extra 5 CU × 720 hours × $0.008
   │  ├─ = $28.80/month additional
   │  └─ Total: ~$209/month
   └─ WAF_v2 adds ~$80-100/month to base

════════════════════════════════════════════════════════════════════════════════════════════

🎯 USE CASES & SCENARIOS
│
├─ Web Application Load Balancing
│  ├─ Multi-Tier Applications
│  │  ├─ Frontend web servers
│  │  ├─ API middleware tier
│  │  ├─ Path-based routing
│  │  └─ Backend database tier
│  │
│  ├─ Microservices Architecture
│  │  ├─ Route by URL path to services
│  │  ├─ /users → User Service
│  │  ├─ /orders → Order Service
│  │  └─ /products → Product Service
│  │
│  └─ Single Page Applications (SPA)
│     ├─ Static content routing
│     ├─ API gateway pattern
│     └─ WebSocket support
│
├─ Multi-Site Hosting
│  ├─ Multiple Domains
│  │  ├─ www.company-a.com
│  │  ├─ www.company-b.com
│  │  ├─ Separate backends per site
│  │  └─ Individual SSL certificates
│  │
│  ├─ Subdomain Hosting
│  │  ├─ app.company.com
│  │  ├─ api.company.com
│  │  ├─ admin.company.com
│  │  └─ Shared or separate backends
│  │
│  └─ White-Label SaaS
│     ├─ customer1.saas.com
│     ├─ customer2.saas.com
│     ├─ Tenant isolation
│     └─ Custom branding per tenant
│
├─ API Gateway Pattern
│  ├─ API Management
│  │  ├─ Central entry point for APIs
│  │  ├─ API versioning (/v1, /v2)
│  │  ├─ Rate limiting per client
│  │  └─ WAF protection for APIs
│  │
│  ├─ Backend for Frontend (BFF)
│  │  ├─ Aggregate multiple backend calls
│  │  ├─ Transform responses
│  │  ├─ Mobile vs web backends
│  │  └─ Simplified client integration
│  │
│  └─ RESTful Services
│     ├─ HTTPS termination
│     ├─ Authentication/authorization
│     ├─ Request/response transformation
│     └─ Analytics & monitoring
│
├─ Security Scenarios
│  ├─ WAF Protection
│  │  ├─ OWASP Top 10 mitigation
│  │  ├─ Bot protection
│  │  ├─ DDoS mitigation (Layer 7)
│  │  └─ Custom rule enforcement
│  │
│  ├─ SSL/TLS Offloading
│  │  ├─ Centralized certificate management
│  │  ├─ Reduce backend CPU load
│  │  ├─ Enforce TLS 1.2+
│  │  └─ Strong cipher suites
│  │
│  └─ Zero Trust Architecture
│     ├─ mTLS authentication
│     ├─ Header-based auth injection
│     ├─ Private Link connectivity
│     └─ Network segmentation
│
├─ Deployment Patterns
│  ├─ Blue-Green Deployment
│  │  ├─ Blue environment (current)
│  │  ├─ Green environment (new)
│  │  ├─ Instant switch via routing rule
│  │  └─ Easy rollback capability
│  │
│  ├─ Canary Releases
│  │  ├─ Route 5% traffic to new version
│  │  ├─ Gradual increase after validation
│  │  ├─ Monitor metrics & errors
│  │  └─ Rollback if issues detected
│  │
│  └─ A/B Testing
│     ├─ Route based on user segment
│     ├─ Header-based routing
│     ├─ Cookie-based routing
│     └─ Feature flag integration
│
├─ Hybrid Cloud Scenarios
│  ├─ Cloud Bursting
│  │  ├─ On-premises primary
│  │  ├─ Azure for overflow traffic
│  │  ├─ Seamless failover
│  │  └─ Cost-effective scaling
│  │
│  ├─ Migration Scenarios
│  │  ├─ Gradual migration to cloud
│  │  ├─ Route old requests on-prem
│  │  ├─ Route new requests to Azure
│  │  └─ Minimize migration risk
│  │
│  └─ Data Residency
│     ├─ Process in specific region
│     ├─ Route based on user location
│     ├─ Compliance requirements
│     └─ Local data processing
│
├─ Internal Applications
│  ├─ Private App Gateway (internal IP)
│  │  ├─ No internet exposure
│  │  ├─ VPN/ExpressRoute access
│  │  ├─ Internal corporate apps
│  │  └─ Enhanced security
│  │
│  ├─ Partner Extranet
│  │  ├─ Private Link connectivity
│  │  ├─ Partner VNet access
│  │  ├─ No public exposure
│  │  └─ Secure B2B integration
│  │
│  └─ Dev/Test Environments
│     ├─ Internal-only access
│     ├─ Lower SKU for cost savings
│     ├─ Isolated from production
│     └─ Testing new configurations
│
└─ Advanced Patterns
   ├─ Global Load Balancing
   │  ├─ Front Door + App Gateway
   │  ├─ Region-level load balancing
   │  ├─ Cross-region failover
   │  └─ Latency-based routing
   │
   ├─ Edge Computing
   │  ├─ Regional processing
   │  ├─ Content transformation
   │  ├─ Protocol conversion
   │  └─ Request enrichment
   │
   └─ Service Mesh Integration
      ├─ Ingress controller for AKS
      ├─ Istio integration
      ├─ Traffic management
      └─ Observability

════════════════════════════════════════════════════════════════════════════════════════════

🆚 SERVICE COMPARISON & DECISION MATRIX
│
├─ Application Gateway vs Azure Load Balancer
│  ├─ Feature Comparison
│  │  ├─ Layer: App Gateway (L7) | Load Balancer (L4)
│  │  ├─ Protocol: HTTP/HTTPS/WebSocket | TCP/UDP (any)
│  │  ├─ Routing: URL/Host-based | IP/Port only
│  │  ├─ SSL: Termination + E2E | No SSL features
│  │  ├─ WAF: Yes | No
│  │  ├─ Scope: Regional | Regional
│  │  ├─ Price: Moderate-High | Low
│  │  └─ Health Probes: HTTP/HTTPS | TCP/HTTP
│  │
│  └─ When to Choose
│     ├─ App Gateway: Web apps, SSL, WAF, L7 routing
│     └─ Load Balancer: Non-HTTP, simple L4, cost-sensitive
│
├─ Application Gateway vs Azure Front Door
│  ├─ Feature Comparison
│  │  ├─ Scope: Regional | Global (multi-region)
│  │  ├─ Routing: Within region | Cross-region
│  │  ├─ CDN: No (use separate) | Yes (built-in)
│  │  ├─ Caching: No native | Yes (edge caching)
│  │  ├─ SSL: Yes | Yes
│  │  ├─ WAF: Yes | Yes (global WAF)
│  │  ├─ Latency: Low (single region) | Lower (edge POP)
│  │  ├─ Failover: Within region | Cross-region
│  │  └─ Price: Moderate | Higher
│  │
│  └─ When to Choose
│     ├─ App Gateway: Single region, advanced L7
│     ├─ Front Door: Global apps, CDN, multi-region
│     └─ Combined: Front Door → Regional App Gateways
│
├─ Application Gateway vs Traffic Manager
│  ├─ Feature Comparison
│  │  ├─ Layer: L7 (Application) | DNS-level
│  │  ├─ Routing: Real-time | DNS resolution
│  │  ├─ Load Balancing: Yes | No (DNS only)
│  │  ├─ SSL Termination: Yes | No
│  │  ├─ Geographic Routing: No | Yes
│  │  ├─ Performance Routing: Within region | Global
│  │  ├─ Protocols: HTTP/HTTPS | Any (DNS-level)
│  │  └─ TTL: N/A | DNS TTL delay
│  │
│  └─ When to Choose
│     ├─ App Gateway: L7 load balancing, SSL
│     ├─ Traffic Manager: DNS routing, any protocol
│     └─ Combined: Traffic Manager → Regional App Gateways
│
├─ Application Gateway vs API Management
│  ├─ Feature Comparison
│  │  ├─ Primary Purpose: Load balancer | API gateway
│  │  ├─ API Management: Limited | Extensive
│  │  ├─ Developer Portal: No | Yes
│  │  ├─ Rate Limiting: Via WAF | Built-in quota/throttling
│  │  ├─ Authentication: SSL, mTLS | OAuth, JWT, keys
│  │  ├─ Transformation: Headers, URL | Full request/response
│  │  ├─ Monitoring: Standard | API-specific analytics
│  │  ├─ Caching: No native | Response caching
│  │  └─ Price: Moderate | Moderate-High
│  │
│  └─ When to Choose
│     ├─ App Gateway: General web load balancing
│     ├─ APIM: API-first, monetization, policies
│     └─ Combined: APIM → App Gateway → Backends
│
└─ Decision Tree
   ├─ Need L4 load balancing? → Azure Load Balancer
   ├─ Need global distribution? → Azure Front Door
   ├─ Need DNS-based routing? → Traffic Manager
   ├─ API-first with management? → API Management
   ├─ Regional web apps with L7? → Application Gateway
   └─ Complex scenarios? → Combination of services

════════════════════════════════════════════════════════════════════════════════════════════

🧠 MEMORY AIDS & QUICK REFERENCE
│
├─ Acronym: "SMART PROWL"
│  ├─ S - Security (WAF, SSL/TLS, mTLS)
│  ├─ M - Multi-site hosting
│  ├─ A - Autoscaling (v2)
│  ├─ R - Routing (URL & host-based)
│  ├─ T - Termination (SSL offloading)
│  ├─ P - Probes (health monitoring)
│  ├─ R - Redundancy (zone redundancy)
│  ├─ O - Observability (metrics & logs)
│  ├─ W - WebSocket support
│  └─ L - Layer 7 load balancing
│
├─ Component Flow: "FLBHPR"
│  ├─ F - Frontend (public/private IP)
│  ├─ L - Listener (port, protocol, host)
│  ├─ B - Backend pool (target servers)
│  ├─ H - HTTP settings (communication config)
│  ├─ P - Probe (health checks)
│  └─ R - Rule (ties everything together)
│
├─ SKU Selection: "v2 Always"
│  ├─ v2 = Modern features
│  ├─ v1 = Legacy (avoid)
│  ├─ Standard_v2 = No WAF
│  └─ WAF_v2 = With WAF protection
│
├─ Routing Types: "BPM"
│  ├─ B - Basic (one-to-one)
│  ├─ P - Path-based (URL routing)
│  └─ M - Multi-site (host-based)
│
├─ SSL Modes: "TOE"
│  ├─ T - Termination (decrypt at gateway)
│  ├─ O - Offloading (same as termination)
│  └─ E - End-to-end (decrypt & re-encrypt)
│
├─ Health Probe States: "HUD"
│  ├─ H - Healthy (backend available)
│  ├─ U - Unhealthy (backend down)
│  └─ D - Draining (graceful removal)
│
├─ Critical Metrics: "HU-FRT"
│  ├─ H - Healthy host count
│  ├─ U - Unhealthy host count
│  ├─ F - Failed requests
│  ├─ R - Response time
│  └─ T - Total requests
│
└─ Quick Decision Matrix
   ├─ Public web app? → Public IP + SSL + WAF
   ├─ Internal app? → Private IP only
   ├─ Multiple domains? → Multi-site listener
   ├─ Path routing? → URL path map
   ├─ API security? → WAF + SSL + mTLS
   ├─ High availability? → Zone redundancy + 2+ instances
   ├─ Cost-sensitive? → Autoscale with low min capacity
   └─ Global app? → Front Door + regional App Gateways

════════════════════════════════════════════════════════════════════════════════════════════
```

## 🔑 Key Takeaways

### **Always Remember:**
1. **v2 SKU is the standard** - Always use Standard_v2 or WAF_v2 (never v1)
2. **Dedicated subnet required** - Minimum /28, recommend /24
3. **Layer 7 only** - HTTP/HTTPS/WebSocket (use Load Balancer for L4)
4. **Regional service** - Deploy in each region, use Front Door for global
5. **Health probes are critical** - Always configure custom probes
6. **Zone redundancy for HA** - Deploy across zones for 99.99% SLA
7. **WAF in prevention mode** - Start in detection, move to prevention after tuning

### **Common Gotchas:**
- ❌ NSG rules must allow 65200-65535 for management
- ❌ Cannot change zones after creation
- ❌ Autoscaling takes 6-7 minutes
- ❌ UDRs can break connectivity if misconfigured
- ❌ Backend timeouts must match application response times
- ❌ Fixed cost regardless of traffic (always running)

### **Best Practices Checklist:**
- ✅ Use v2 SKU (Standard_v2 or WAF_v2)
- ✅ Enable zone redundancy (3 zones)
- ✅ Configure autoscaling (min: 2, max: realistic)
- ✅ Enable WAF in prevention mode
- ✅ Use TLS 1.2+ only
- ✅ Configure custom health probes
- ✅ Enable diagnostic logging
- ✅ Set up alerts for unhealthy hosts
- ✅ Use Key Vault for certificates
- ✅ Tag resources for cost tracking
- ✅ Multiple backends per pool
- ✅ Connection draining enabled
- ✅ Regular security audits

---

## Overview

**Azure Application Gateway** is a web traffic load balancer that enables you to manage traffic to your web applications. It operates at the **Application Layer (OSI Layer 7)** and provides advanced request routing, SSL/TLS termination, Web Application Firewall (WAF), and autoscaling capabilities.

### Key Characteristics
- **Layer 7 Load Balancer**: Makes routing decisions based on HTTP/HTTPS attributes
- **Regional Service**: Deployed within a specific Azure region
- **PaaS Service**: Fully managed by Azure with high availability
- **Application-aware**: Can route based on URL path, host headers, cookies, etc.

---

## Key Features

### 1. **URL-Based Routing**
Route requests to different backend pools based on URL path patterns.

```plaintext
Example:
/images/* → Image Server Pool
/api/*    → API Server Pool
/video/*  → Video Server Pool
```

### 2. **Multi-Site Hosting**
Host multiple websites on the same Application Gateway instance using different domain names.

```plaintext
www.contoso.com → Backend Pool A
www.fabrikam.com → Backend Pool B
```

### 3. **SSL/TLS Termination**
- Offload CPU-intensive SSL/TLS encryption/decryption from backend servers
- Centralized certificate management
- End-to-end SSL encryption support

### 4. **Web Application Firewall (WAF)**
- Protection against common web vulnerabilities (OWASP Top 10)
- Custom rules and managed rule sets
- Prevention and Detection modes
- Bot protection

### 5. **Autoscaling**
- Automatically scale up or down based on traffic load
- Available in Application Gateway v2 SKU

### 6. **Session Affinity (Cookie-Based)**
Keep user sessions on the same backend server using cookie-based session persistence.

### 7. **Connection Draining**
Gracefully remove backend servers from rotation without dropping active connections.

### 8. **Custom Health Probes**
Define custom health checks to monitor backend server availability.

### 9. **HTTP to HTTPS Redirection**
Automatically redirect HTTP traffic to HTTPS.

### 10. **WebSocket and HTTP/2 Support**
Native support for real-time communication protocols.

### 11. **Zone Redundancy**
Deploy across Availability Zones for higher availability (v2 SKU).

### 12. **Private Link Support**
Enable private connectivity to Application Gateway from on-premises or other VNets.

---

## Components and Architecture

### Core Components

#### 1. **Frontend IP Configuration**
- **Public IP**: Exposed to the internet
- **Private IP**: Internal-only access
- **Dual IP**: Both public and private

#### 2. **Listeners**
Receive incoming traffic and match rules based on:
- Port number
- Protocol (HTTP/HTTPS)
- Hostname
- SSL certificate

**Types:**
- **Basic Listener**: Single site
- **Multi-site Listener**: Multiple hostnames

#### 3. **Backend Pools**
Collection of backend servers:
- Azure VMs
- VM Scale Sets
- App Services
- IP addresses or FQDNs
- On-premises servers (via VPN/ExpressRoute)

#### 4. **HTTP Settings**
Configure how traffic is sent to backend:
- Protocol (HTTP/HTTPS)
- Port
- Cookie-based affinity
- Connection draining
- Request timeout
- Custom probes
- Host name override

#### 5. **Routing Rules**
Associate listeners with backend pools and HTTP settings:
- **Basic Rule**: One listener → One backend pool
- **Path-based Rule**: URL path → Different backend pools

#### 6. **Health Probes**
Monitor backend server health:
- Default probes (automatic)
- Custom probes (configurable path, interval, timeout)

### Architecture Diagram

```plaintext
Internet
    ↓
[Public IP / Private IP]
    ↓
[Application Gateway]
    ├── Listener 1 (Port 80/443)
    ├── Listener 2 (Multi-site)
    ├── WAF Rules
    ├── SSL Certificate
    └── Routing Rules
            ↓
    [Backend Pools]
        ├── VM Scale Set
        ├── App Service
        └── VMs in VNet
```

---

## SKU Options

### Application Gateway v1 (Legacy)

| SKU | Features | Autoscaling | Zone Redundancy |
|-----|----------|-------------|-----------------|
| **Standard_Small** | Basic features | ❌ | ❌ |
| **Standard_Medium** | Basic features | ❌ | ❌ |
| **Standard_Large** | Basic features | ❌ | ❌ |
| **WAF_Medium** | WAF included | ❌ | ❌ |
| **WAF_Large** | WAF included | ❌ | ❌ |

### Application Gateway v2 (Recommended)

| SKU | Features | Autoscaling | Zone Redundancy |
|-----|----------|-------------|-----------------|
| **Standard_v2** | All v2 features | ✅ | ✅ |
| **WAF_v2** | WAF + all v2 features | ✅ | ✅ |

**v2 SKU Benefits:**
- Autoscaling
- Zone redundancy
- Static VIP
- Header rewriting
- Azure Key Vault integration
- Better performance
- Faster deployment updates

---

## When to Use Application Gateway

### ✅ **Use Application Gateway When:**

1. **Advanced HTTP/HTTPS Routing**
   - Need URL-based routing
   - Hosting multiple websites
   - Need host header-based routing

2. **SSL/TLS Termination**
   - Centralized certificate management
   - Offload SSL processing from backends

3. **Web Application Security**
   - Protection against OWASP Top 10
   - Bot protection
   - Custom security rules

4. **Regional Load Balancing**
   - Load balance within a single Azure region
   - Layer 7 features required

5. **Hybrid Scenarios**
   - Route traffic to on-premises and cloud resources
   - Mix of Azure services (VMs, App Services)

### ❌ **Don't Use Application Gateway When:**

1. **Layer 4 Load Balancing Needed**
   - Use Azure Load Balancer instead
   - Non-HTTP/HTTPS protocols (TCP/UDP)

2. **Global Load Balancing Required**
   - Use Azure Front Door or Traffic Manager
   - Multi-region failover/routing

3. **Simple Static Website**
   - Use Azure CDN or Azure Static Web Apps
   - No dynamic routing needed

4. **Cost-Sensitive Scenarios**
   - Fixed costs regardless of traffic
   - Consider alternatives for dev/test

---

## Configuration Options

### 1. **Frontend Configuration**

```json
{
  "name": "appGwPublicFrontendIp",
  "properties": {
    "publicIPAddress": {
      "id": "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/publicIPAddresses/{pip-name}"
    }
  }
}
```

### 2. **Backend Pool Configuration**

```json
{
  "name": "apiBackendPool",
  "properties": {
    "backendAddresses": [
      { "fqdn": "api1.contoso.com" },
      { "fqdn": "api2.contoso.com" },
      { "ipAddress": "10.0.1.10" }
    ]
  }
}
```

### 3. **HTTP Settings**

```json
{
  "name": "httpSettings",
  "properties": {
    "port": 80,
    "protocol": "Http",
    "cookieBasedAffinity": "Enabled",
    "connectionDraining": {
      "enabled": true,
      "drainTimeoutInSec": 60
    },
    "requestTimeout": 30,
    "probe": {
      "id": "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/applicationGateways/{ag-name}/probes/{probe-name}"
    }
  }
}
```

### 4. **Custom Health Probe**

```json
{
  "name": "customHealthProbe",
  "properties": {
    "protocol": "Http",
    "host": "api.contoso.com",
    "path": "/health",
    "interval": 30,
    "timeout": 30,
    "unhealthyThreshold": 3,
    "pickHostNameFromBackendHttpSettings": false,
    "match": {
      "statusCodes": ["200-399"]
    }
  }
}
```

### 5. **URL Path-Based Routing**

```json
{
  "name": "pathRule",
  "properties": {
    "paths": ["/api/*"],
    "backendAddressPool": {
      "id": "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/applicationGateways/{ag-name}/backendAddressPools/apiBackendPool"
    },
    "backendHttpSettings": {
      "id": "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/applicationGateways/{ag-name}/backendHttpSettingsCollection/apiHttpSettings"
    }
  }
}
```

---

## Code Examples

### Azure CLI

#### Create Application Gateway

```bash
# Create a resource group
az group create \
  --name myResourceGroup \
  --location eastus

# Create a VNet and subnet
az network vnet create \
  --resource-group myResourceGroup \
  --name myVNet \
  --address-prefix 10.0.0.0/16 \
  --subnet-name myAGSubnet \
  --subnet-prefix 10.0.1.0/24

# Create a public IP
az network public-ip create \
  --resource-group myResourceGroup \
  --name myAGPublicIPAddress \
  --sku Standard \
  --allocation-method Static

# Create Application Gateway v2
az network application-gateway create \
  --name myAppGateway \
  --resource-group myResourceGroup \
  --location eastus \
  --vnet-name myVNet \
  --subnet myAGSubnet \
  --capacity 2 \
  --sku Standard_v2 \
  --http-settings-cookie-based-affinity Disabled \
  --frontend-port 80 \
  --http-settings-port 80 \
  --http-settings-protocol Http \
  --public-ip-address myAGPublicIPAddress \
  --priority 100
```

#### Add Backend Pool

```bash
az network application-gateway address-pool create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name apiBackendPool \
  --servers api1.contoso.com api2.contoso.com
```

#### Configure URL Path-Based Routing

```bash
# Create backend pool for images
az network application-gateway address-pool create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name imageBackendPool \
  --servers img1.contoso.com img2.contoso.com

# Create HTTP settings for images
az network application-gateway http-settings create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name imageHttpSettings \
  --port 80 \
  --protocol Http \
  --cookie-based-affinity Disabled

# Create URL path map
az network application-gateway url-path-map create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name urlPathMap \
  --paths /images/* \
  --address-pool imageBackendPool \
  --http-settings imageHttpSettings \
  --default-address-pool apiBackendPool \
  --default-http-settings httpSettings

# Create path-based routing rule
az network application-gateway rule create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name pathBasedRule \
  --http-listener myListener \
  --rule-type PathBasedRouting \
  --url-path-map urlPathMap \
  --priority 200
```

#### Configure SSL/TLS

```bash
# Upload SSL certificate
az network application-gateway ssl-cert create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name mySslCert \
  --cert-file /path/to/cert.pfx \
  --cert-password "P@ssw0rd"

# Create HTTPS listener
az network application-gateway http-listener create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name httpsListener \
  --frontend-port 443 \
  --ssl-cert mySslCert
```

#### Enable WAF

```bash
# Create WAF policy
az network application-gateway waf-policy create \
  --name myWafPolicy \
  --resource-group myResourceGroup

# Configure WAF policy
az network application-gateway waf-policy policy-setting update \
  --policy-name myWafPolicy \
  --resource-group myResourceGroup \
  --mode Prevention \
  --state Enabled \
  --max-request-body-size-in-kb 128

# Associate WAF policy with Application Gateway
az network application-gateway update \
  --name myAppGateway \
  --resource-group myResourceGroup \
  --set firewallPolicy.id="/subscriptions/{sub-id}/resourceGroups/myResourceGroup/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/myWafPolicy"
```

### PowerShell

#### Create Application Gateway

```powershell
# Define variables
$resourceGroup = "myResourceGroup"
$location = "EastUS"
$vnetName = "myVNet"
$subnetName = "myAGSubnet"
$pipName = "myAGPublicIPAddress"
$agName = "myAppGateway"

# Create resource group
New-AzResourceGroup -Name $resourceGroup -Location $location

# Create VNet and subnet
$subnet = New-AzVirtualNetworkSubnetConfig `
  -Name $subnetName `
  -AddressPrefix 10.0.1.0/24

$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $resourceGroup `
  -Location $location `
  -Name $vnetName `
  -AddressPrefix 10.0.0.0/16 `
  -Subnet $subnet

# Create public IP
$pip = New-AzPublicIpAddress `
  -ResourceGroupName $resourceGroup `
  -Location $location `
  -Name $pipName `
  -AllocationMethod Static `
  -Sku Standard

# Get subnet
$subnet = Get-AzVirtualNetworkSubnetConfig `
  -Name $subnetName `
  -VirtualNetwork $vnet

# Create frontend IP config
$fipconfig = New-AzApplicationGatewayFrontendIPConfig `
  -Name "frontendIP" `
  -PublicIPAddress $pip

# Create frontend port
$frontendport = New-AzApplicationGatewayFrontendPort `
  -Name "frontendPort" `
  -Port 80

# Create backend pool
$backendPool = New-AzApplicationGatewayBackendAddressPool `
  -Name "backendPool" `
  -BackendIPAddresses 10.0.2.10, 10.0.2.11

# Create HTTP settings
$poolSettings = New-AzApplicationGatewayBackendHttpSettings `
  -Name "httpSettings" `
  -Port 80 `
  -Protocol Http `
  -CookieBasedAffinity Disabled `
  -RequestTimeout 30

# Create listener
$listener = New-AzApplicationGatewayHttpListener `
  -Name "listener" `
  -Protocol Http `
  -FrontendIPConfiguration $fipconfig `
  -FrontendPort $frontendport

# Create routing rule
$rule = New-AzApplicationGatewayRequestRoutingRule `
  -Name "rule1" `
  -RuleType Basic `
  -Priority 100 `
  -HttpListener $listener `
  -BackendAddressPool $backendPool `
  -BackendHttpSettings $poolSettings

# Create SKU
$sku = New-AzApplicationGatewaySku `
  -Name Standard_v2 `
  -Tier Standard_v2 `
  -Capacity 2

# Create Application Gateway
$appgw = New-AzApplicationGateway `
  -Name $agName `
  -ResourceGroupName $resourceGroup `
  -Location $location `
  -BackendAddressPools $backendPool `
  -BackendHttpSettingsCollection $poolSettings `
  -FrontendIpConfigurations $fipconfig `
  -GatewayIpConfigurations $gipconfig `
  -FrontendPorts $frontendport `
  -HttpListeners $listener `
  -RequestRoutingRules $rule `
  -Sku $sku
```

#### Configure Autoscaling

```powershell
$appgw = Get-AzApplicationGateway -Name $agName -ResourceGroupName $resourceGroup

# Configure autoscaling
$appgw = Set-AzApplicationGatewayAutoscaleConfiguration `
  -ApplicationGateway $appgw `
  -MinCapacity 2 `
  -MaxCapacity 10

# Update Application Gateway
Set-AzApplicationGateway -ApplicationGateway $appgw
```

### ARM Template

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "applicationGatewayName": {
      "type": "string",
      "defaultValue": "myAppGateway"
    },
    "tier": {
      "type": "string",
      "defaultValue": "Standard_v2",
      "allowedValues": ["Standard_v2", "WAF_v2"]
    },
    "skuSize": {
      "type": "string",
      "defaultValue": "Standard_v2",
      "allowedValues": ["Standard_v2", "WAF_v2"]
    },
    "minCapacity": {
      "type": "int",
      "defaultValue": 2,
      "minValue": 0,
      "maxValue": 125
    },
    "maxCapacity": {
      "type": "int",
      "defaultValue": 10,
      "minValue": 2,
      "maxValue": 125
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]"
    }
  },
  "variables": {
    "vnetName": "appGwVNet",
    "subnetName": "appGwSubnet",
    "publicIPAddressName": "appGwPublicIP",
    "vnetAddressPrefix": "10.0.0.0/16",
    "subnetAddressPrefix": "10.0.1.0/24"
  },
  "resources": [
    {
      "type": "Microsoft.Network/publicIPAddresses",
      "apiVersion": "2021-05-01",
      "name": "[variables('publicIPAddressName')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "Standard"
      },
      "properties": {
        "publicIPAllocationMethod": "Static"
      }
    },
    {
      "type": "Microsoft.Network/virtualNetworks",
      "apiVersion": "2021-05-01",
      "name": "[variables('vnetName')]",
      "location": "[parameters('location')]",
      "properties": {
        "addressSpace": {
          "addressPrefixes": ["[variables('vnetAddressPrefix')]"]
        },
        "subnets": [
          {
            "name": "[variables('subnetName')]",
            "properties": {
              "addressPrefix": "[variables('subnetAddressPrefix')]"
            }
          }
        ]
      }
    },
    {
      "type": "Microsoft.Network/applicationGateways",
      "apiVersion": "2021-05-01",
      "name": "[parameters('applicationGatewayName')]",
      "location": "[parameters('location')]",
      "dependsOn": [
        "[resourceId('Microsoft.Network/virtualNetworks', variables('vnetName'))]",
        "[resourceId('Microsoft.Network/publicIPAddresses', variables('publicIPAddressName'))]"
      ],
      "properties": {
        "sku": {
          "name": "[parameters('skuSize')]",
          "tier": "[parameters('tier')]"
        },
        "autoscaleConfiguration": {
          "minCapacity": "[parameters('minCapacity')]",
          "maxCapacity": "[parameters('maxCapacity')]"
        },
        "gatewayIPConfigurations": [
          {
            "name": "appGatewayIpConfig",
            "properties": {
              "subnet": {
                "id": "[resourceId('Microsoft.Network/virtualNetworks/subnets', variables('vnetName'), variables('subnetName'))]"
              }
            }
          }
        ],
        "frontendIPConfigurations": [
          {
            "name": "appGwPublicFrontendIp",
            "properties": {
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses', variables('publicIPAddressName'))]"
              }
            }
          }
        ],
        "frontendPorts": [
          {
            "name": "port_80",
            "properties": {
              "port": 80
            }
          },
          {
            "name": "port_443",
            "properties": {
              "port": 443
            }
          }
        ],
        "backendAddressPools": [
          {
            "name": "defaultBackendPool",
            "properties": {
              "backendAddresses": []
            }
          }
        ],
        "backendHttpSettingsCollection": [
          {
            "name": "defaultHttpSettings",
            "properties": {
              "port": 80,
              "protocol": "Http",
              "cookieBasedAffinity": "Disabled",
              "requestTimeout": 30
            }
          }
        ],
        "httpListeners": [
          {
            "name": "defaultHttpListener",
            "properties": {
              "frontendIPConfiguration": {
                "id": "[resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', parameters('applicationGatewayName'), 'appGwPublicFrontendIp')]"
              },
              "frontendPort": {
                "id": "[resourceId('Microsoft.Network/applicationGateways/frontendPorts', parameters('applicationGatewayName'), 'port_80')]"
              },
              "protocol": "Http"
            }
          }
        ],
        "requestRoutingRules": [
          {
            "name": "defaultRoutingRule",
            "properties": {
              "ruleType": "Basic",
              "priority": 100,
              "httpListener": {
                "id": "[resourceId('Microsoft.Network/applicationGateways/httpListeners', parameters('applicationGatewayName'), 'defaultHttpListener')]"
              },
              "backendAddressPool": {
                "id": "[resourceId('Microsoft.Network/applicationGateways/backendAddressPools', parameters('applicationGatewayName'), 'defaultBackendPool')]"
              },
              "backendHttpSettings": {
                "id": "[resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', parameters('applicationGatewayName'), 'defaultHttpSettings')]"
              }
            }
          }
        ]
      }
    }
  ],
  "outputs": {
    "publicIP": {
      "type": "string",
      "value": "[reference(resourceId('Microsoft.Network/publicIPAddresses', variables('publicIPAddressName'))).ipAddress]"
    }
  }
}
```

### Bicep

```bicep
param applicationGatewayName string = 'myAppGateway'
param location string = resourceGroup().location
param tier string = 'Standard_v2'
param skuSize string = 'Standard_v2'
param minCapacity int = 2
param maxCapacity int = 10
param zones array = ['1', '2', '3']

// VNet
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'appGwVNet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'appGwSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'backendSubnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

// Public IP
resource publicIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'appGwPublicIP'
  location: location
  sku: {
    name: 'Standard'
  }
  zones: zones
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Application Gateway
resource applicationGateway 'Microsoft.Network/applicationGateways@2021-05-01' = {
  name: applicationGatewayName
  location: location
  zones: zones
  properties: {
    sku: {
      name: skuSize
      tier: tier
    }
    autoscaleConfiguration: {
      minCapacity: minCapacity
      maxCapacity: maxCapacity
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/appGwSubnet'
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'apiBackendPool'
        properties: {
          backendAddresses: []
        }
      }
      {
        name: 'webBackendPool'
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'httpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          connectionDraining: {
            enabled: true
            drainTimeoutInSec: 60
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'routingRule'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'httpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'apiBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'httpSettings')
          }
        }
      }
    ]
  }
}

output applicationGatewayId string = applicationGateway.id
output publicIPAddress string = publicIP.properties.ipAddress
```

### Terraform

```hcl
# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Variables
variable "resource_group_name" {
  default = "myResourceGroup"
}

variable "location" {
  default = "East US"
}

variable "app_gateway_name" {
  default = "myAppGateway"
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "appGwVNet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
}

# Subnet for Application Gateway
resource "azurerm_subnet" "appgw" {
  name                 = "appGwSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "main" {
  name                = "appGwPublicIP"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

# Application Gateway
resource "azurerm_application_gateway" "main" {
  name                = var.app_gateway_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  zones               = ["1", "2", "3"]

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 2
    max_capacity = 10
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = "frontendPort80"
    port = 80
  }

  frontend_port {
    name = "frontendPort443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIp"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  backend_address_pool {
    name = "apiBackendPool"
    fqdns = [
      "api1.contoso.com",
      "api2.contoso.com"
    ]
  }

  backend_address_pool {
    name = "webBackendPool"
  }

  backend_http_settings {
    name                  = "httpSettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30

    connection_draining {
      enabled           = true
      drain_timeout_sec = 60
    }

    probe_name = "healthProbe"
  }

  probe {
    name                = "healthProbe"
    protocol            = "Http"
    path                = "/health"
    host                = "127.0.0.1"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3

    match {
      status_code = ["200-399"]
    }
  }

  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "appGwPublicFrontendIp"
    frontend_port_name             = "frontendPort80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routingRule"
    rule_type                  = "Basic"
    http_listener_name         = "httpListener"
    backend_address_pool_name  = "apiBackendPool"
    backend_http_settings_name = "httpSettings"
    priority                   = 100
  }

  # URL Path Map for path-based routing
  url_path_map {
    name                               = "urlPathMap"
    default_backend_address_pool_name  = "webBackendPool"
    default_backend_http_settings_name = "httpSettings"

    path_rule {
      name                       = "apiPathRule"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "apiBackendPool"
      backend_http_settings_name = "httpSettings"
    }
  }

  # WAF Configuration (if using WAF_v2 SKU)
  # waf_configuration {
  #   enabled          = true
  #   firewall_mode    = "Prevention"
  #   rule_set_type    = "OWASP"
  #   rule_set_version = "3.2"
  # }

  tags = {
    environment = "production"
  }
}

# Outputs
output "public_ip_address" {
  value = azurerm_public_ip.main.ip_address
}

output "application_gateway_id" {
  value = azurerm_application_gateway.main.id
}
```

### .NET SDK (C#)

```csharp
using Azure;
using Azure.Identity;
using Azure.ResourceManager;
using Azure.ResourceManager.Network;
using Azure.ResourceManager.Network.Models;
using Azure.ResourceManager.Resources;

public class ApplicationGatewayManager
{
    private readonly ArmClient _client;
    private readonly string _subscriptionId;
    private readonly string _resourceGroupName;
    private readonly string _location;

    public ApplicationGatewayManager(string subscriptionId, string resourceGroupName, string location)
    {
        _client = new ArmClient(new DefaultAzureCredential());
        _subscriptionId = subscriptionId;
        _resourceGroupName = resourceGroupName;
        _location = location;
    }

    public async Task<ApplicationGatewayResource> CreateApplicationGatewayAsync(
        string appGatewayName,
        string vnetName,
        string subnetName,
        string publicIpName)
    {
        // Get subscription and resource group
        var subscription = await _client.GetSubscriptionResource(
            new ResourceIdentifier($"/subscriptions/{_subscriptionId}")).GetAsync();
        var resourceGroup = await subscription.Value.GetResourceGroupAsync(_resourceGroupName);

        // Get existing VNet and subnet
        var vnetCollection = resourceGroup.Value.GetVirtualNetworks();
        var vnet = await vnetCollection.GetAsync(vnetName);
        var subnet = vnet.Value.Data.Subnets.First(s => s.Name == subnetName);

        // Get existing Public IP
        var publicIpCollection = resourceGroup.Value.GetPublicIPAddresses();
        var publicIp = await publicIpCollection.GetAsync(publicIpName);

        // Create Application Gateway
        var appGatewayData = new ApplicationGatewayData
        {
            Location = _location,
            Sku = new ApplicationGatewaySku
            {
                Name = ApplicationGatewaySkuName.StandardV2,
                Tier = ApplicationGatewayTier.StandardV2
            },
            AutoscaleConfiguration = new ApplicationGatewayAutoscaleConfiguration
            {
                MinCapacity = 2,
                MaxCapacity = 10
            }
        };

        // Gateway IP Configuration
        appGatewayData.GatewayIPConfigurations.Add(new ApplicationGatewayIPConfiguration
        {
            Name = "appGatewayIpConfig",
            Subnet = new SubResource { Id = subnet.Id }
        });

        // Frontend IP Configuration
        appGatewayData.FrontendIPConfigurations.Add(new ApplicationGatewayFrontendIPConfiguration
        {
            Name = "appGwPublicFrontendIp",
            PublicIPAddress = new SubResource { Id = publicIp.Value.Id }
        });

        // Frontend Ports
        appGatewayData.FrontendPorts.Add(new ApplicationGatewayFrontendPort
        {
            Name = "port_80",
            Port = 80
        });

        appGatewayData.FrontendPorts.Add(new ApplicationGatewayFrontendPort
        {
            Name = "port_443",
            Port = 443
        });

        // Backend Address Pool
        appGatewayData.BackendAddressPools.Add(new ApplicationGatewayBackendAddressPool
        {
            Name = "apiBackendPool"
        });

        // Backend HTTP Settings
        appGatewayData.BackendHttpSettingsCollection.Add(new ApplicationGatewayBackendHttpSettings
        {
            Name = "httpSettings",
            Port = 80,
            Protocol = ApplicationGatewayProtocol.Http,
            CookieBasedAffinity = ApplicationGatewayCookieBasedAffinity.Disabled,
            RequestTimeout = 30,
            ConnectionDraining = new ApplicationGatewayConnectionDraining
            {
                Enabled = true,
                DrainTimeoutInSec = 60
            }
        });

        // HTTP Listener
        appGatewayData.HttpListeners.Add(new ApplicationGatewayHttpListener
        {
            Name = "httpListener",
            Protocol = ApplicationGatewayProtocol.Http,
            FrontendIPConfiguration = new SubResource
            {
                Id = new ResourceIdentifier($"{appGatewayData.Id}/frontendIPConfigurations/appGwPublicFrontendIp")
            },
            FrontendPort = new SubResource
            {
                Id = new ResourceIdentifier($"{appGatewayData.Id}/frontendPorts/port_80")
            }
        });

        // Request Routing Rule
        appGatewayData.RequestRoutingRules.Add(new ApplicationGatewayRequestRoutingRule
        {
            Name = "routingRule",
            RuleType = ApplicationGatewayRequestRoutingRuleType.Basic,
            Priority = 100,
            HttpListener = new SubResource
            {
                Id = new ResourceIdentifier($"{appGatewayData.Id}/httpListeners/httpListener")
            },
            BackendAddressPool = new SubResource
            {
                Id = new ResourceIdentifier($"{appGatewayData.Id}/backendAddressPools/apiBackendPool")
            },
            BackendHttpSettings = new SubResource
            {
                Id = new ResourceIdentifier($"{appGatewayData.Id}/backendHttpSettingsCollection/httpSettings")
            }
        });

        // Create the Application Gateway
        var appGatewayCollection = resourceGroup.Value.GetApplicationGateways();
        var operation = await appGatewayCollection.CreateOrUpdateAsync(
            WaitUntil.Completed,
            appGatewayName,
            appGatewayData);

        return operation.Value;
    }

    public async Task AddBackendServerAsync(
        string appGatewayName,
        string backendPoolName,
        string backendFqdn)
    {
        var subscription = await _client.GetSubscriptionResource(
            new ResourceIdentifier($"/subscriptions/{_subscriptionId}")).GetAsync();
        var resourceGroup = await subscription.Value.GetResourceGroupAsync(_resourceGroupName);
        var appGatewayCollection = resourceGroup.Value.GetApplicationGateways();
        var appGateway = await appGatewayCollection.GetAsync(appGatewayName);

        var backendPool = appGateway.Value.Data.BackendAddressPools
            .First(p => p.Name == backendPoolName);
        
        backendPool.BackendAddresses.Add(new ApplicationGatewayBackendAddress
        {
            Fqdn = backendFqdn
        });

        await appGatewayCollection.CreateOrUpdateAsync(
            WaitUntil.Completed,
            appGatewayName,
            appGateway.Value.Data);
    }
}

// Usage
var manager = new ApplicationGatewayManager(
    "your-subscription-id",
    "myResourceGroup",
    "eastus");

var appGateway = await manager.CreateApplicationGatewayAsync(
    "myAppGateway",
    "myVNet",
    "appGwSubnet",
    "myPublicIP");

Console.WriteLine($"Application Gateway created: {appGateway.Id}");
```

---

## Advanced Features

### 1. **Header Rewriting**

Modify HTTP headers in requests and responses.

```bash
# Create rewrite rule set
az network application-gateway rewrite-rule set create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name myRewriteRuleSet

# Add rewrite rule
az network application-gateway rewrite-rule create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --rule-set-name myRewriteRuleSet \
  --name addCustomHeader \
  --sequence 100

# Add condition
az network application-gateway rewrite-rule condition create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --rule-set-name myRewriteRuleSet \
  --rule-name addCustomHeader \
  --variable "http_req_Authorization" \
  --pattern ".*" \
  --ignore-case true

# Add action to insert header
az network application-gateway rewrite-rule action set create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --rule-set-name myRewriteRuleSet \
  --rule-name addCustomHeader \
  --request-headers X-Custom-Header=CustomValue
```

**Use Cases:**
- Add security headers (X-Frame-Options, X-Content-Type-Options)
- Remove server identification headers
- Add custom routing headers
- Modify Host headers for backend compatibility

### 2. **URL Rewrite**

Rewrite URL paths before routing to backend.

```json
{
  "name": "urlRewriteRule",
  "actionSet": {
    "urlConfiguration": {
      "modifiedPath": "/api/v2{var_uri_path}",
      "modifiedQueryString": "version=2.0",
      "reroute": false
    }
  }
}
```

### 3. **Custom Error Pages**

Configure custom error pages for 4xx and 5xx errors.

```bash
az network application-gateway custom-error create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --status-code 502 \
  --custom-error-page-url "https://mycdn.com/error-502.html"
```

### 4. **Private Link**

Enable private connectivity to Application Gateway.

```bash
# Create private link configuration
az network application-gateway private-link add \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name myPrivateLink \
  --frontend-ip appGwPublicFrontendIp \
  --subnet-prefix 10.0.3.0/24

# Create private endpoint (from another VNet)
az network private-endpoint create \
  --name myPrivateEndpoint \
  --resource-group myResourceGroup \
  --vnet-name clientVNet \
  --subnet clientSubnet \
  --private-connection-resource-id <app-gateway-id> \
  --group-id <private-link-config-id> \
  --connection-name myConnection
```

### 5. **Mutual TLS (mTLS)**

Require client certificates for authentication.

```bash
# Upload trusted root certificate
az network application-gateway root-cert create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name trustedRootCert \
  --cert-file /path/to/root-cert.cer

# Configure SSL profile with client auth
az network application-gateway ssl-profile add \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name clientAuthProfile \
  --trusted-client-certificates trustedRootCert \
  --client-auth-configuration true
```

### 6. **Key Vault Integration**

Store SSL certificates in Azure Key Vault.

```bash
# Create managed identity for App Gateway
az identity create \
  --name appGwIdentity \
  --resource-group myResourceGroup

# Assign identity to Application Gateway
az network application-gateway identity assign \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --identity appGwIdentity

# Grant Key Vault access
az keyvault set-policy \
  --name myKeyVault \
  --object-id <managed-identity-principal-id> \
  --secret-permissions get list

# Reference certificate from Key Vault
az network application-gateway ssl-cert create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name kvCert \
  --key-vault-secret-id "https://mykeyvault.vault.azure.net/secrets/mycert"
```

### 7. **HTTP/2 Support**

HTTP/2 is enabled by default on Application Gateway v2. No configuration needed.

### 8. **IP Allow/Deny Lists**

Implement IP filtering using WAF custom rules.

```bash
# Create custom rule to block specific IPs
az network application-gateway waf-policy custom-rule create \
  --policy-name myWafPolicy \
  --resource-group myResourceGroup \
  --name blockBadIPs \
  --priority 10 \
  --rule-type MatchRule \
  --action Block

# Add match condition
az network application-gateway waf-policy custom-rule match-condition add \
  --policy-name myWafPolicy \
  --resource-group myResourceGroup \
  --name blockBadIPs \
  --match-variables RemoteAddr \
  --operator IPMatch \
  --values 1.2.3.4 5.6.7.8
```

---

## Best Practices

### 1. **Design and Architecture**

✅ **Use Application Gateway v2 SKU**
- Autoscaling capabilities
- Zone redundancy
- Better performance
- More features

✅ **Deploy Across Availability Zones**
```bash
--zones 1 2 3
```

✅ **Separate Subnets**
- Dedicated subnet for Application Gateway
- /24 or larger for future scaling
- Don't share with other resources

✅ **Use Private Backend Pools**
- Keep backend servers in private subnets
- No public IPs needed on backends

✅ **Plan for Scaling**
```json
{
  "autoscaleConfiguration": {
    "minCapacity": 2,
    "maxCapacity": 10
  }
}
```

### 2. **Security**

✅ **Enable WAF**
```bash
--sku WAF_v2
--waf-policy myWafPolicy
```

✅ **Use Prevention Mode** (after testing)
```bash
--mode Prevention
```

✅ **SSL/TLS Best Practices**
- Use TLS 1.2 or higher only
- Disable weak cipher suites
- Implement end-to-end SSL for sensitive data
- Use Key Vault for certificate management

✅ **Restrict Network Access**
- Use NSGs on Application Gateway subnet
- Allow only required ports (80, 443)
- Whitelist Azure infrastructure IPs (65200-65535)

✅ **Enable Diagnostic Logging**
```bash
az monitor diagnostic-settings create \
  --name appGwDiagnostics \
  --resource <app-gateway-id> \
  --logs '[{"category": "ApplicationGatewayAccessLog", "enabled": true}]' \
  --workspace <log-analytics-workspace-id>
```

### 3. **Performance**

✅ **Use HTTP/2**
- Enabled by default on v2
- Better performance for modern browsers

✅ **Enable Connection Draining**
```json
{
  "connectionDraining": {
    "enabled": true,
    "drainTimeoutInSec": 60
  }
}
```

✅ **Optimize Health Probes**
- Use lightweight endpoints
- Set appropriate intervals
- Monitor probe failures

✅ **Configure Request Timeout**
```json
{
  "requestTimeout": 30
}
```

✅ **Use Cookie-Based Affinity** (when needed)
```bash
--cookie-based-affinity Enabled
```

### 4. **Cost Optimization**

✅ **Right-Size Autoscaling**
```json
{
  "minCapacity": 2,  // Start low
  "maxCapacity": 10  // Set realistic limits
}
```

✅ **Monitor Unused Instances**
- Review capacity utilization metrics
- Adjust min/max capacity

✅ **Use Reserved Capacity** (for predictable workloads)
- 1-year or 3-year commitments
- Significant cost savings

✅ **Consolidate Applications**
- Host multiple sites on one gateway
- Use multi-site hosting
- Path-based routing

### 5. **Reliability**

✅ **Implement Health Probes**
```json
{
  "probe": {
    "protocol": "Http",
    "path": "/health",
    "interval": 30,
    "timeout": 30,
    "unhealthyThreshold": 3
  }
}
```

✅ **Configure Backend Timeout**
- Match backend processing time
- Account for slow queries

✅ **Use Multiple Backend Servers**
- At least 2 per pool
- Distribute across availability zones

✅ **Monitor Metrics**
- Unhealthy host count
- Failed requests
- Response time
- Throughput

### 6. **Monitoring**

✅ **Enable Diagnostics**
- Access logs
- Performance logs
- Firewall logs (WAF)

✅ **Key Metrics to Monitor**
- **Healthy/Unhealthy Host Count**
- **Failed Requests**
- **Response Status** (2xx, 3xx, 4xx, 5xx)
- **Throughput**
- **Compute Units**
- **Current Connections**
- **Backend Response Time**

✅ **Set Up Alerts**
```bash
az monitor metrics alert create \
  --name unhealthyHostAlert \
  --resource-group myResourceGroup \
  --scopes <app-gateway-id> \
  --condition "avg UnhealthyHostCount > 0" \
  --description "Alert when backend hosts are unhealthy"
```

---

## Comparison with Other Services

### Application Gateway vs Azure Load Balancer

| Feature | Application Gateway | Azure Load Balancer |
|---------|-------------------|-------------------|
| **OSI Layer** | Layer 7 (Application) | Layer 4 (Transport) |
| **Protocol** | HTTP/HTTPS | TCP/UDP (any) |
| **Routing** | URL-based, host-based | IP/Port only |
| **SSL Termination** | ✅ Yes | ❌ No |
| **WAF** | ✅ Yes | ❌ No |
| **Scope** | Regional | Regional |
| **Use Case** | Web applications | General TCP/UDP load balancing |

### Application Gateway vs Azure Front Door

| Feature | Application Gateway | Azure Front Door |
|---------|-------------------|------------------|
| **Scope** | Regional | Global |
| **Routing** | Within region | Multi-region |
| **CDN** | ❌ No | ✅ Yes |
| **SSL Offload** | ✅ Yes | ✅ Yes |
| **WAF** | ✅ Yes | ✅ Yes |
| **Latency** | Lower (single region) | Lower (edge locations) |
| **Use Case** | Regional apps | Global apps |
| **Failover** | Within region | Cross-region |

### Application Gateway vs Traffic Manager

| Feature | Application Gateway | Traffic Manager |
|---------|-------------------|-----------------|
| **Layer** | Layer 7 | DNS-level |
| **Load Balancing** | Real-time | DNS resolution |
| **SSL Termination** | ✅ Yes | ❌ No |
| **Geographic Routing** | ❌ No | ✅ Yes |
| **Use Case** | Regional HTTP/HTTPS | Global DNS-based routing |

### When to Use Each

**Use Application Gateway when:**
- Single-region web applications
- Need Layer 7 routing (URL paths, headers)
- SSL/TLS termination required
- WAF protection needed

**Use Azure Load Balancer when:**
- Non-HTTP protocols (TCP/UDP)
- Simple port-based routing
- Ultra-low latency required
- Cost-sensitive scenarios

**Use Azure Front Door when:**
- Global web applications
- Multi-region deployment
- CDN capabilities needed
- Cross-region failover required

**Use Traffic Manager when:**
- DNS-based global routing
- Geographic/performance-based routing
- Disaster recovery across regions
- Any protocol (DNS-level)

---

## Common Scenarios

### Scenario 1: Multi-Tier Web Application

```plaintext
Internet → Application Gateway (WAF enabled)
              ↓
        Frontend Pool (Web Servers)
              ↓
        Internal Load Balancer
              ↓
        API Pool (API Servers)
              ↓
        Backend Database
```

**Configuration:**
- Path-based routing: `/` → Web servers, `/api/*` → API servers
- SSL termination at Application Gateway
- WAF in prevention mode
- Health probes for each tier

### Scenario 2: Multi-Site Hosting

Host multiple websites on one Application Gateway:

```plaintext
www.contoso.com → Backend Pool A
www.fabrikam.com → Backend Pool B
www.northwind.com → Backend Pool C
```

**Configuration:**
```bash
# Create multi-site listeners
az network application-gateway http-listener create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name contosoListener \
  --frontend-port 443 \
  --host-name www.contoso.com \
  --ssl-cert contosoCert

az network application-gateway http-listener create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name fabrikamListener \
  --frontend-port 443 \
  --host-name www.fabrikam.com \
  --ssl-cert fabrikamCert
```

### Scenario 3: Blue-Green Deployment

Use Application Gateway for zero-downtime deployments:

```plaintext
Application Gateway
    ├── Blue Environment (Current: 100%)
    └── Green Environment (New: 0%)

After validation:
    ├── Blue Environment (Current: 0%)
    └── Green Environment (New: 100%)
```

**Implementation:**
```bash
# Adjust weights in backend settings
# Blue: 100%, Green: 0%
az network application-gateway address-pool update \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name bluePool \
  --servers blue-vm1 blue-vm2

# After testing, switch to green
az network application-gateway rule update \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name mainRule \
  --address-pool greenPool
```

### Scenario 4: API Gateway Pattern

Use as an API Gateway with versioning:

```plaintext
/api/v1/* → Backend Pool V1
/api/v2/* → Backend Pool V2
/api/v3/* → Backend Pool V3
```

**Configuration:**
```bash
az network application-gateway url-path-map create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name apiVersionMap \
  --paths "/api/v1/*" \
  --address-pool apiV1Pool \
  --http-settings apiHttpSettings \
  --default-address-pool apiV3Pool \
  --default-http-settings apiHttpSettings

az network application-gateway url-path-map rule create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --path-map-name apiVersionMap \
  --name v2Rule \
  --paths "/api/v2/*" \
  --address-pool apiV2Pool \
  --http-settings apiHttpSettings
```

### Scenario 5: Hybrid Cloud Architecture

Connect on-premises and Azure resources:

```plaintext
Internet → Application Gateway
              ↓
        ┌─────┴─────┐
        ↓           ↓
   Azure VMs    On-Premises Servers
                (via VPN/ExpressRoute)
```

**Configuration:**
```bash
# Add on-premises servers to backend pool
az network application-gateway address-pool create \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name hybridPool \
  --servers 10.0.1.10 192.168.1.20  # Azure and on-prem IPs
```

---

## Monitoring and Troubleshooting

### Key Metrics

#### Resource Health
```bash
az network application-gateway show-backend-health \
  --name myAppGateway \
  --resource-group myResourceGroup
```

#### Access Logs
```json
{
  "timeStamp": "2026-03-11T10:00:00Z",
  "clientIP": "1.2.3.4",
  "httpMethod": "GET",
  "requestUri": "/api/users",
  "httpStatus": 200,
  "userAgent": "Mozilla/5.0...",
  "timeTaken": 0.234
}
```

#### Performance Logs
```json
{
  "instanceId": "appgw_0",
  "healthyHostCount": 2,
  "unhealthyHostCount": 0,
  "requestCount": 1000,
  "avgRequestTime": 0.150
}
```

### Common Issues and Solutions

#### Issue 1: Unhealthy Backend Hosts

**Symptoms:**
- 502 Bad Gateway errors
- Unhealthy host count > 0

**Troubleshooting:**
```bash
# Check backend health
az network application-gateway show-backend-health \
  --name myAppGateway \
  --resource-group myResourceGroup \
  --output table

# Check NSG rules
az network nsg rule list \
  --nsg-name backendNSG \
  --resource-group myResourceGroup \
  --output table
```

**Solutions:**
1. Verify backend servers are running
2. Check NSG rules allow traffic from Application Gateway subnet
3. Verify health probe path returns 200 OK
4. Check firewall rules on backend servers
5. Verify backend timeout is sufficient

#### Issue 2: SSL Certificate Errors

**Symptoms:**
- HTTPS requests fail
- Certificate warnings in browser

**Solutions:**
```bash
# Verify certificate is uploaded
az network application-gateway ssl-cert list \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup

# Check certificate expiration
az network application-gateway ssl-cert show \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name mySslCert

# Update certificate
az network application-gateway ssl-cert update \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup \
  --name mySslCert \
  --cert-file /path/to/new-cert.pfx \
  --cert-password "NewPassword"
```

#### Issue 3: High Latency

**Symptoms:**
- Slow response times
- Backend response time metric is high

**Troubleshooting:**
```bash
# Monitor metrics
az monitor metrics list \
  --resource <app-gateway-id> \
  --metric BackendResponseTime \
  --start-time 2026-03-11T00:00:00Z \
  --end-time 2026-03-11T23:59:59Z
```

**Solutions:**
1. Optimize backend application performance
2. Add more backend servers
3. Enable connection draining
4. Use cookie-based affinity if needed
5. Increase request timeout
6. Check network connectivity
7. Verify DNS resolution time

#### Issue 4: WAF Blocking Legitimate Traffic

**Symptoms:**
- 403 Forbidden errors
- Legitimate requests blocked

**Troubleshooting:**
```bash
# Check WAF logs
az monitor diagnostic-settings create \
  --name wafLogs \
  --resource <app-gateway-id> \
  --logs '[{"category": "ApplicationGatewayFirewallLog", "enabled": true}]' \
  --workspace <log-analytics-workspace-id>

# Query logs in Log Analytics
```

**Solutions:**
1. Start with Detection mode, then move to Prevention
2. Review firewall logs to identify rules blocking traffic
3. Create exclusions for false positives
4. Tune WAF rule sets
5. Create custom rules to allow specific patterns

#### Issue 5: Autoscaling Not Working

**Symptoms:**
- Gateway not scaling under load
- Performance degradation

**Troubleshooting:**
```bash
# Check autoscale configuration
az network application-gateway show \
  --name myAppGateway \
  --resource-group myResourceGroup \
  --query autoscaleConfiguration

# Monitor capacity units
az monitor metrics list \
  --resource <app-gateway-id> \
  --metric CapacityUnits
```

**Solutions:**
1. Verify v2 SKU is being used
2. Check capacity units metric
3. Increase max capacity if needed
4. Monitor compute units utilization
5. Verify no resource limits are reached

### Diagnostic Commands

```bash
# Get Application Gateway details
az network application-gateway show \
  --name myAppGateway \
  --resource-group myResourceGroup

# Check backend health
az network application-gateway show-backend-health \
  --name myAppGateway \
  --resource-group myResourceGroup

# List all probes
az network application-gateway probe list \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup

# Check routing rules
az network application-gateway rule list \
  --gateway-name myAppGateway \
  --resource-group myResourceGroup

# View firewall logs (WAF)
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "AzureDiagnostics | where ResourceType == 'APPLICATIONGATEWAYS' and Category == 'ApplicationGatewayFirewallLog'"
```

---

## Pricing

### Cost Components

1. **Fixed Hourly Rate**
   - Charged per hour regardless of traffic
   - Varies by SKU and region

2. **Capacity Units**
   - Consumed based on:
     - Compute units (processing)
     - Persistent connections
     - Throughput (data processed)
   - First 5 capacity units included in fixed rate

3. **Data Processing**
   - v1 SKU: Charged per GB processed
   - v2 SKU: Included in capacity units

4. **WAF**
   - Additional cost for WAF_v2 SKU
   - Charged per policy and rules evaluated

### Pricing Example (v2 SKU - Standard_v2)

```plaintext
Fixed Cost: ~$0.25/hour (~$180/month)
Plus: Capacity Units beyond first 5
Plus: Outbound data transfer

Capacity Unit Calculation:
- Compute unit: Based on CPU usage
- Connection unit: 2,500 persistent connections
- Throughput unit: 2.22 Mbps
```

### Cost Optimization Tips

1. **Use Autoscaling Wisely**
   - Set appropriate min/max capacity
   - Monitor actual usage

2. **Consolidate Applications**
   - Host multiple sites on one gateway
   - Use path-based routing

3. **Reserved Capacity**
   - 1-year or 3-year commitment
   - Up to 30% savings

4. **Review Data Processing**
   - Monitor throughput
   - Optimize data transfer

---

## Summary

**Azure Application Gateway** is a powerful Layer 7 load balancer ideal for:
- ✅ HTTP/HTTPS applications requiring advanced routing
- ✅ SSL/TLS termination and centralized certificate management
- ✅ Web application security with integrated WAF
- ✅ Multi-site hosting and URL-based routing
- ✅ Regional applications with high availability requirements

**Key Takeaways:**
1. Always use **v2 SKU** for new deployments
2. Enable **autoscaling** for variable workloads
3. Deploy across **Availability Zones** for high availability
4. Use **WAF** for web application protection
5. Implement **health probes** for backend monitoring
6. Enable **diagnostic logging** for troubleshooting
7. Follow **security best practices** (TLS 1.2+, strong ciphers)
8. Monitor key metrics (health, latency, throughput)

For global applications or multi-region deployments, consider using **Azure Front Door** in combination with regional Application Gateways.

---

## Additional Resources

- [Official Documentation](https://docs.microsoft.com/azure/application-gateway/)
- [Application Gateway FAQ](https://docs.microsoft.com/azure/application-gateway/application-gateway-faq)
- [WAF Documentation](https://docs.microsoft.com/azure/web-application-firewall/)
- [Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)
- [Architecture Center](https://docs.microsoft.com/azure/architecture/browse/)
