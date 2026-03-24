# 12 — Performance Tuning & EXPLAIN ANALYZE
> Part of: [PostgreSQL Complete Guide](README.md)

---

## 12. Performance Tuning & EXPLAIN ANALYZE

```
┌─────────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: EXPLAIN ANALYZE is PostgreSQL's execution plan viewer.   │
│  Like SQL Server's "Include Actual Execution Plan" — but more detailed  │
│  and with more options.                                                 │
└─────────────────────────────────────────────────────────────────────────┘
```

### EXPLAIN ANALYZE

```sql
-- Basic plan
EXPLAIN SELECT * FROM app.users WHERE email = 'alice@example.com';

-- Full analysis with buffers (most useful)
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT u.email, COUNT(p.id) AS post_count
FROM   app.users u
LEFT JOIN app.posts p ON p.user_id = u.id
WHERE  u.is_active = true
GROUP  BY u.email
ORDER  BY post_count DESC;

-- Reading the output:
-- Seq Scan     = Full table scan (BAD on large tables)
-- Index Scan   = Used index (GOOD)
-- Index Only Scan = Read from index only (BEST)
-- Nested Loop  = Good for small tables
-- Hash Join    = Good for medium tables
-- Merge Join   = Good for sorted large tables
-- cost=0.00..X.XX rows=N  = Estimated cost
-- actual time=X..Y rows=N = Actual timing
-- Buffers: hit=N read=M   = Cache hits vs disk reads
```

### Key postgresql.conf Settings

```ini
# WHY: shared_buffers should be 25% of RAM (SQL Server auto-manages buffer pool)
shared_buffers = 4GB

# WHY: work_mem is per-sort/hash operation — too low = spills to disk
work_mem = 256MB

# WHY: effective_cache_size tells planner how much OS cache is available
effective_cache_size = 12GB

# WHY: max_connections — PG uses one process per connection (expensive)
# Use pgBouncer connection pooler for >100 connections
max_connections = 200

# WHY: enable JIT compilation for complex analytical queries (PG 11+)
jit = on

# WHY: autovacuum keeps dead tuples cleaned up (critical for MVCC)
autovacuum = on
autovacuum_vacuum_scale_factor = 0.05   # vacuum when 5% of rows are dead

# WAL settings for replication
wal_level = replica
max_wal_senders = 10
```

### Common Performance Patterns

```sql
-- ── Check for missing indexes (slow queries) ─────────────────────────
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM   pg_stats
WHERE  tablename = 'users';

-- ── Table bloat — check if vacuum needed ─────────────────────────────
SELECT relname, n_dead_tup, n_live_tup,
       ROUND(100 * n_dead_tup::NUMERIC / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_pct
FROM   pg_stat_user_tables
WHERE  n_dead_tup > 1000
ORDER  BY dead_pct DESC;

-- ── Slow query log via pg_stat_statements ────────────────────────────
-- Enable in postgresql.conf: shared_preload_libraries = 'pg_stat_statements'
SELECT query, calls, total_exec_time / calls AS avg_ms, rows
FROM   pg_stat_statements
ORDER  BY avg_ms DESC
LIMIT  20;

-- ── Index usage statistics ───────────────────────────────────────────
SELECT indexrelname, idx_scan, idx_tup_read, idx_tup_fetch
FROM   pg_stat_user_indexes
WHERE  idx_scan = 0      -- unused indexes
ORDER  BY pg_relation_size(indexrelid) DESC;

-- ── Manual VACUUM and ANALYZE ────────────────────────────────────────
VACUUM ANALYZE app.users;      -- reclaim dead tuples + update stats
VACUUM FULL app.users;         -- full rewrite (locks table — use with care)
CLUSTER app.posts USING idx_posts_user_id;  -- physically reorder rows
```

### Partitioning (like SQL Server table partitioning)

```sql
-- Range partitioning by date (common for time-series/events)
CREATE TABLE app.events (
    id          BIGINT GENERATED ALWAYS AS IDENTITY,
    event_type  TEXT NOT NULL,
    payload     JSONB,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY RANGE (created_at);

-- Create monthly partitions
CREATE TABLE app.events_2024_01 PARTITION OF app.events
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE app.events_2024_02 PARTITION OF app.events
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Queries automatically route to correct partition
SELECT * FROM app.events WHERE created_at >= '2024-01-15';
```

---

*[← Previous: Stored Procedures & Triggers](11_Stored_Procedures_Triggers.md) | [Back to Index](README.md) | [Next: Replication & HA →](13_Replication_HA.md)*
