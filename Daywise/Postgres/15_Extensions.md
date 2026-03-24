# 15 — PostgreSQL Extensions Ecosystem
> Part of: [PostgreSQL Complete Guide](README.md)

---

## 15. PostgreSQL Extensions Ecosystem

```
┌─────────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Extensions are like NuGet packages for PostgreSQL —      │
│  they add capabilities without needing a separate server.               │
└─────────────────────────────────────────────────────────────────────────┘
```

### Top Extensions

| Extension | Purpose | Use Case |
|-----------|---------|---------|
| **pgvector** | Vector similarity search | AI embeddings, semantic search |
| **PostGIS** | Geospatial data | Location-based apps, mapping |
| **TimescaleDB** | Time-series optimization | IoT, metrics, financial data |
| **pg_stat_statements** | Query performance stats | Performance monitoring |
| **pgcrypto** | Encryption functions | Data encryption |
| **pg_cron** | Scheduled jobs | Replacing SQL Agent |
| **uuid-ossp** | UUID generation | UUID v1-v5 |
| **hstore** | Key-value store (legacy, use JSONB) | Simple K-V |
| **pg_partman** | Automatic partition management | Large time-series tables |
| **Citus** | Horizontal sharding | Multi-node distributed PG |
| **pg_audit** | Detailed audit logging | Compliance (SOC2, HIPAA) |
| **pgBouncer** | Connection pooler | High-concurrency apps |
| **HypoPG** | Hypothetical indexes | Index planning without building |

```sql
-- Install an extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS vector;  -- pgvector

-- Check installed extensions
SELECT * FROM pg_extension;
```

---

*[← Previous: Security](14_Security.md) | [Back to Index](README.md) | [Next: pgvector (AI Vector DB) →](16_pgvector.md)*
