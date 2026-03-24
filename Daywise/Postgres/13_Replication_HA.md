# 13 — Replication & High Availability
> Part of: [PostgreSQL Complete Guide](README.md)

---

## 13. Replication & High Availability

```
┌─────────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: PostgreSQL streaming replication is like SQL Server      │
│  Always On Availability Groups — primary sends WAL to standby replicas. │
└─────────────────────────────────────────────────────────────────────────┘
```

### Replication Types

| Type | Use Case | SQL Server Equivalent |
|------|---------|----------------------|
| **Streaming replication** | HA, read replicas | Always On AG |
| **Logical replication** | Selective table sync, migrations | Transactional replication |
| **Patroni** | Automatic failover cluster | AG with auto-failover |
| **pgBouncer** | Connection pooling | SQL Server connection pooling |
| **Citus** | Horizontal sharding | Distributed availability groups |

```sql
-- Check replication lag
SELECT
    client_addr,
    state,
    sent_lsn - replay_lsn AS replication_lag_bytes
FROM pg_stat_replication;

-- Create read-only replica connection (in app)
-- primary: writes  → host=primary-host
-- replica: reads   → host=replica-host
```

---

*[← Previous: Performance Tuning](12_Performance_Tuning.md) | [Back to Index](README.md) | [Next: Security →](14_Security.md)*
