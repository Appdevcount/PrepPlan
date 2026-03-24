# 18 — PostgreSQL on Azure (Flexible Server)
> Part of: [PostgreSQL Complete Guide](README.md)

---

## 🎬 Quick Learn

| Format | Video |
|--------|-------|
| **☁️ Azure PG Setup** | [Azure Database for PostgreSQL Flexible Server — YouTube Search](https://www.youtube.com/results?search_query=azure+database+postgresql+flexible+server+setup+tutorial+2024) |
| **🔧 Bicep/CLI** | [Azure PostgreSQL Bicep ARM Template — YouTube Search](https://www.youtube.com/results?search_query=azure+postgresql+flexible+server+bicep+azure+cli+tutorial) |
| **🏗️ Microsoft Learn** | [Azure Friday — PostgreSQL Flexible Server intro](https://www.youtube.com/results?search_query=azure+friday+postgresql+flexible+server+managed+database) |

---

## 18. PostgreSQL on Azure (Flexible Server)

```
┌─────────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Azure Database for PostgreSQL Flexible Server is like    │
│  Azure SQL Managed Instance — fully managed, but you control server     │
│  parameters and extensions.                                             │
└─────────────────────────────────────────────────────────────────────────┘
```

### Azure PostgreSQL Flexible Server — Key Features

| Feature | Details |
|---------|---------|
| **Versions** | PostgreSQL 11, 12, 13, 14, 15, 16 |
| **pgvector** | Supported (enable as extension) |
| **High Availability** | Zone-redundant HA with standby |
| **Read replicas** | Up to 5 read replicas |
| **Backup** | 1-35 day retention, geo-redundant |
| **Scaling** | Compute: stop/start, resize; Storage: online expand |
| **Private endpoint** | VNet integration |
| **Microsoft Entra auth** | Azure AD login support |
| **Connection pooling** | Built-in PgBouncer |

### Bicep Template

```bicep
// ── Azure PostgreSQL Flexible Server ─────────────────────────────────
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-06-01-preview' = {
  name:     'psql-myapp-prod'
  location: location
  sku: {
    name: 'Standard_D4ds_v5'   // 4 vCores, 16 GB RAM
    tier: 'GeneralPurpose'
  }
  properties: {
    administratorLogin:         'pgadmin'
    administratorLoginPassword: adminPassword
    version:                    '16'
    storage: {
      storageSizeGB: 128
      autoGrow: 'Enabled'
    }
    backup: {
      backupRetentionDays:  7
      geoRedundantBackup:  'Enabled'
    }
    highAvailability: {
      mode:                     'ZoneRedundant'
      standbyAvailabilityZone: '2'
    }
    // WHY: disable public access, use private endpoint
    network: {
      publicNetworkAccess: 'Disabled'
    }
  }
}

// Enable pgvector extension
resource pgvectorConfig 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2023-06-01-preview' = {
  parent: postgresServer
  name:   'azure.extensions'
  properties: {
    value:  'VECTOR'    // enable pgvector
    source: 'user-override'
  }
}
```

### Azure CLI Setup

```bash
# Create Flexible Server
az postgres flexible-server create \
  --name psql-myapp-dev \
  --resource-group rg-myapp \
  --location eastus \
  --admin-user pgadmin \
  --admin-password "SecureP@ss123" \
  --sku-name Standard_D2ds_v5 \
  --tier GeneralPurpose \
  --version 16 \
  --storage-size 32 \
  --public-access None

# Enable pgvector
az postgres flexible-server parameter set \
  --server-name psql-myapp-dev \
  --resource-group rg-myapp \
  --name azure.extensions \
  --value VECTOR

# Create database
az postgres flexible-server db create \
  --server-name psql-myapp-dev \
  --resource-group rg-myapp \
  --database-name appdb

# Connect
az postgres flexible-server connect \
  --name psql-myapp-dev \
  --admin-user pgadmin \
  --database-name appdb
```

### Supabase — PostgreSQL + pgvector SaaS

```
Supabase is a great option for AI projects:
- Managed PostgreSQL with pgvector pre-installed
- Free tier: 500 MB DB + 50K vector dimensions
- Built-in REST API (PostgREST), Auth, Storage
- Dashboard with vector search UI
- SDK for JavaScript, Python, Swift, Kotlin, .NET

Connection string from Supabase dashboard:
postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres
```

---

*[← Previous: .NET / EF Core](17_DotNet_EFCore.md) | [Back to Index](README.md) | [Next: Production Checklist →](19_Production_Checklist.md)*
