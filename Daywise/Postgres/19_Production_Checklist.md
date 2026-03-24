# 19 — Production Checklist & Monitoring
> Part of: [PostgreSQL Complete Guide](README.md)

---

## 🎬 Quick Learn

| Format | Video |
|--------|-------|
| **🔭 Monitoring** | [PostgreSQL Monitoring Production — YouTube Search](https://www.youtube.com/results?search_query=postgresql+production+monitoring+pg_stat_activity+tutorial) |
| **🔄 pgBouncer** | [pgBouncer Connection Pooling Tutorial — YouTube Search](https://www.youtube.com/results?search_query=pgbouncer+connection+pooling+postgresql+tutorial+setup) |
| **✅ Checklist** | [PostgreSQL Production Checklist Best Practices — YouTube Search](https://www.youtube.com/results?search_query=postgresql+production+checklist+security+performance+best+practices) |
| **🏗️ Channel** | [Crunchy Data PostgreSQL Channel](https://www.youtube.com/c/CrunchyDataPostgres) — production DBA content |

---

## 19. Production Checklist & Monitoring

### Configuration Checklist

```sql
-- ── Must-Do Security ─────────────────────────────────────────────────
-- 1. Disable public schema default privileges
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- 2. Use separate roles per service
CREATE ROLE api_service_role;
CREATE USER api_user WITH PASSWORD '...';
GRANT api_service_role TO api_user;

-- 3. Enable SSL (in postgresql.conf)
-- ssl = on
-- ssl_cert_file = 'server.crt'
-- ssl_key_file  = 'server.key'

-- 4. Enable audit logging
ALTER SYSTEM SET log_connections = 'on';
ALTER SYSTEM SET log_disconnections = 'on';
ALTER SYSTEM SET log_duration = 'off';
ALTER SYSTEM SET log_min_duration_statement = '1000'; -- log queries > 1s
SELECT pg_reload_conf();

-- ── Monitoring Queries ───────────────────────────────────────────────
-- Active connections
SELECT count(*), state FROM pg_stat_activity GROUP BY state;

-- Long-running queries (> 30 seconds)
SELECT pid, now() - pg_stat_activity.query_start AS duration, query, state
FROM   pg_stat_activity
WHERE  state != 'idle'
AND    now() - pg_stat_activity.query_start > INTERVAL '30 seconds';

-- Table sizes
SELECT schemaname, relname, pg_size_pretty(pg_total_relation_size(relid)) AS size
FROM   pg_catalog.pg_statio_user_tables
ORDER  BY pg_total_relation_size(relid) DESC
LIMIT  20;

-- Cache hit ratio (should be > 99%)
SELECT
    sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) AS cache_hit_ratio
FROM pg_statio_user_tables;

-- Replication lag
SELECT client_addr, state,
       pg_size_pretty(sent_lsn - replay_lsn) AS lag
FROM   pg_stat_replication;

-- Kill blocking query
SELECT pg_terminate_backend(pid)
FROM   pg_stat_activity
WHERE  pid <> pg_backend_pid()
AND    query_start < NOW() - INTERVAL '5 minutes'
AND    state = 'idle in transaction';
```

### Connection Pooling with pgBouncer

```ini
# pgbouncer.ini
[databases]
mydb = host=localhost port=5432 dbname=mydb

[pgbouncer]
pool_mode = transaction      # transaction-level pooling (most efficient)
max_client_conn = 1000       # total client connections
default_pool_size = 20       # connections to PostgreSQL per database+user
min_pool_size = 5
server_idle_timeout = 600
listen_port = 6432
auth_type = md5
```

```csharp
// Connect through pgBouncer (same connection string, just different port)
"Host=localhost;Port=6432;Database=mydb;Username=app;Password=xxx;"
```

---

*[← Previous: Azure Flexible Server](18_Azure_Flexible_Server.md) | [Back to Index](README.md) | [Next: Interview Q&A →](20_Interview_QA.md)*
