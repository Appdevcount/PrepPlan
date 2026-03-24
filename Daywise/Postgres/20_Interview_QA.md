# 20 — Interview Q&A — 30 Expert Questions
> Part of: [PostgreSQL Complete Guide](README.md)

---

## 🎬 Quick Learn

| Format | Video |
|--------|-------|
| **📘 Full Review** | [PostgreSQL Full Course — freeCodeCamp · 3 hr](https://www.youtube.com/watch?v=SpfIwlAYaKk) — best pre-interview recap |
| **📘 Advanced Topics** | [Learn PostgreSQL — Amigoscode · 4 hr](https://www.youtube.com/watch?v=qw--VYLpxG4) `freeCodeCamp` — covers UPSERT, constraints, joins |
| **🎯 Interview Prep** | [PostgreSQL Interview Questions — YouTube Search](https://www.youtube.com/results?search_query=postgresql+interview+questions+answers+experienced+2024) |
| **🏗️ System Design** | [Database System Design Interview — YouTube Search](https://www.youtube.com/results?search_query=database+system+design+interview+postgresql+microservices+2024) |

---

## 20. Interview Q&A — 30 Expert Questions

### Beginner Level

**Q1: What is the difference between CHAR, VARCHAR, and TEXT in PostgreSQL?**
> A: All three store strings. CHAR(n) is fixed-length and pads with spaces. VARCHAR(n) limits length. TEXT is unlimited. In PostgreSQL, VARCHAR and TEXT have **identical performance** — the only reason to use VARCHAR(n) is to enforce a business rule constraint.

**Q2: What is SERIAL vs GENERATED ALWAYS AS IDENTITY?**
> A: SERIAL is legacy shorthand that creates a sequence and defaults to it. `GENERATED ALWAYS AS IDENTITY` is the SQL standard syntax (PG 10+) that prevents accidental overrides. Prefer IDENTITY — SERIAL can be bypassed by explicit INSERT values.

**Q3: How is ON CONFLICT different from SQL Server's MERGE?**
> A: `INSERT … ON CONFLICT` is atomic and simpler. SQL Server's MERGE has known race conditions. PostgreSQL's `ON CONFLICT` uses the unique constraint name to detect conflicts and is safe for concurrent use.

**Q4: What is the difference between JSON and JSONB?**
> A: JSON stores text as-is and re-parses on each access. JSONB stores as binary, indexes with GIN, and enables fast field-level queries. Always use JSONB unless you need to preserve exact JSON whitespace/key ordering.

### Intermediate Level

**Q5: What is MVCC and why does it matter?**
> A: Multi-Version Concurrency Control means PostgreSQL stores multiple versions of rows. Readers see a consistent snapshot without blocking writers. Old versions accumulate and must be reclaimed by VACUUM. This gives better read concurrency than SQL Server's lock-based approach.

**Q6: When would you use a BRIN index vs a B-Tree index?**
> A: BRIN (Block Range Index) works best on very large tables where the data is **physically ordered** by the indexed column (e.g., a timestamp that increases over time). BRIN is tiny (a few KB vs GB for B-Tree) and perfect for time-series or log tables. B-Tree is better for random access patterns.

**Q7: What is the difference between VACUUM and VACUUM FULL?**
> A: Regular VACUUM reclaims dead tuple space in-place and doesn't shrink the file. It runs online without blocking. VACUUM FULL rewrites the entire table (like DBCC SHRINKFILE), reclaims disk space, but requires an exclusive lock — use with caution in production.

**Q8: What are partial indexes and when are they useful?**
> A: A partial index only indexes rows matching a WHERE clause. Example: `CREATE INDEX ON orders(customer_id) WHERE status = 'pending'` — only indexes pending orders. Much smaller and faster than a full index when you query a subset of rows 99% of the time.

**Q9: Explain the difference between IVFFlat and HNSW indexes in pgvector.**
> A: IVFFlat (Inverted File with Flat index) partitions vectors into lists and searches nearby lists. It requires training (needs data before building) and is memory-efficient. HNSW (Hierarchical Navigable Small World) builds a graph structure, offers better recall and faster queries but uses more memory. For production: prefer HNSW.

**Q10: What is Row-Level Security (RLS) and when would you use it?**
> A: RLS lets you define policies that automatically filter rows based on the current database role or session variables. Use it for multi-tenant applications where users should only see their own data — enforced at the DB level, not application level.

### Advanced Level

**Q11: Explain PostgreSQL's WAL (Write-Ahead Log) and its role in replication.**
> A: Every change is first written to WAL (an append-only sequential log) before modifying data pages. This ensures durability (WAL is flushed to disk before commit) and enables streaming replication (replica replays WAL from primary). WAL is also used for point-in-time recovery (PITR).

**Q12: What is the difference between logical and physical replication?**
> A: Physical replication copies raw WAL bytes — entire cluster, block level, requires same PG version and OS. Logical replication copies decoded change events per table — cross-version, selective tables, can replicate to different schema. Use logical for zero-downtime major version upgrades.

**Q13: How would you implement optimistic concurrency in PostgreSQL?**
> A: Use the system column `xmin` (transaction ID that created/last modified the row). Include it in your UPDATE WHERE clause: `UPDATE users SET … WHERE id = @id AND xmin = @version`. If xmin changed, another transaction modified the row — zero rows updated = concurrency conflict detected.

**Q14: What is connection pooling and why is it critical for PostgreSQL?**
> A: PostgreSQL forks a new OS process per connection (unlike SQL Server's thread model). Each process uses ~5-10MB RAM. At 500 connections = ~4GB RAM just for process overhead. pgBouncer pools connections at transaction level, allowing thousands of app connections to share a small pool of backend connections.

**Q15: How does pgvector's cosine similarity search work at a high level?**
> A: Each document is converted to a high-dimensional vector (embedding) by an ML model. Cosine similarity measures the angle between two vectors — 1.0 = identical direction (similar meaning), 0.0 = perpendicular (unrelated). pgvector's HNSW index navigates a graph to find approximate nearest neighbors without scanning all vectors.

**Q16: How would you implement a semantic search with filtering in pgvector?**
> A: Use `WHERE` clauses before the vector ORDER BY — PostgreSQL's planner applies filters first, reducing the vector search space. For complex filters, use CTEs: filter to candidate set first, then rank by vector distance. This is called "pre-filtering" and is critical for performance.

**Q17: What is the difference between EXPLAIN and EXPLAIN ANALYZE?**
> A: EXPLAIN shows the planner's estimated plan (no execution). EXPLAIN ANALYZE actually runs the query and shows actual vs estimated rows and timing. Add BUFFERS to see cache hits vs disk reads. Add FORMAT JSON for machine parsing. Always use EXPLAIN (ANALYZE, BUFFERS) for real performance diagnosis.

**Q18: When would you partition a table and what are the types?**
> A: Partition when a table exceeds ~50GB or query performance degrades on large tables. Types: **Range** (date ranges — most common), **List** (discrete values like country code), **Hash** (even distribution). Benefits: queries scan only relevant partitions, VACUUM/indexes are per-partition, old partitions can be detached and dropped instantly.

**Q19: What is the RETURNING clause and why is it better than a separate SELECT?**
> A: RETURNING returns modified rows after INSERT/UPDATE/DELETE in a single round-trip. More efficient than INSERT + SELECT. Atomic — you get the actual stored values including computed defaults and trigger-modified values. SQL Server equivalent is OUTPUT INTO but RETURNING is more ergonomic.

**Q20: How would you handle schema migrations safely in production?**
> A:
> 1. **Never use raw `ALTER TABLE … SET NOT NULL`** on large tables — acquires lock
> 2. Add column as nullable first, backfill data, then add NOT NULL constraint
> 3. Use `CREATE INDEX CONCURRENTLY` to avoid locking
> 4. Use `ADD CONSTRAINT … NOT VALID` then `VALIDATE CONSTRAINT` separately
> 5. Test migrations on a replica under production load first

### Expert / Architecture Level

**Q21: How would you design a multi-tenant SaaS on PostgreSQL?**
> A: Three approaches: (1) **Shared schema + RLS** — all tenants in same tables, RLS policies isolate data (cost-effective, harder to customize per tenant); (2) **Schema per tenant** — each tenant gets own schema (good isolation, schema count limit ~10K); (3) **Database per tenant** — strongest isolation, highest cost. Hybrid: use shared schema + RLS for small tenants, separate schemas for enterprise.

**Q22: How does PostgreSQL handle write-heavy workloads efficiently?**
> A: (1) **Batched writes**: insert multiple rows per transaction, (2) **Async commit**: `synchronous_commit = off` for non-critical writes (WAL not flushed on commit — faster but ~1s of data risk), (3) **Unlogged tables**: no WAL writes at all (lost on crash — use for temp/cache data), (4) **COPY command**: 10-100x faster than individual INSERTs for bulk loads, (5) **Table partitioning**: parallelize INSERT across partitions.

**Q23: What is a hot standby and how does it differ from a warm standby?**
> A: Hot standby accepts read-only queries while replaying WAL. Warm standby replays WAL but doesn't accept connections. Hot standby reduces load on primary and is preferred. The standby can serve SELECT queries with a slight replication lag.

**Q24: How would you implement a distributed search across millions of vectors?**
> A: (1) **Partition by namespace/tenant**: each partition has its own HNSW index, queries target relevant partition; (2) **Use Citus**: distribute the vector table across nodes, parallel approximate search; (3) **Hybrid architecture**: for >100M vectors, consider a dedicated vector DB (Qdrant, Milvus) or pgvector with aggressive partitioning + pre-filtering.

**Q25: Explain how you would handle PostgreSQL in a microservices architecture.**
> A: Each microservice owns its database (database per service pattern). Services communicate via events (Service Bus/Kafka), not direct DB joins. Use logical replication or event streaming to propagate data. For read models, project events into service-specific read tables. Use Outbox pattern for reliable event publishing within the same Postgres transaction.

---

### Quick Reference

```sql
-- ── Most Common Commands ─────────────────────────────────────────────

-- Top N per group
SELECT DISTINCT ON (user_id) user_id, title
FROM posts ORDER BY user_id, created_at DESC;

-- Upsert
INSERT INTO t (col) VALUES ($1) ON CONFLICT (col) DO UPDATE SET col = EXCLUDED.col;

-- JSON build
SELECT JSON_BUILD_OBJECT('id', id, 'email', email) FROM users;

-- Array contains
SELECT * FROM t WHERE 'tag' = ANY(tags_array);

-- Date trunc
SELECT DATE_TRUNC('day', created_at), COUNT(*) FROM events GROUP BY 1;

-- Pg version
SELECT version();

-- Table size
SELECT pg_size_pretty(pg_total_relation_size('tablename'));

-- Kill query
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE query LIKE '%slow_query%';

-- Vector search
SELECT id, embedding <=> $1::vector AS distance FROM docs ORDER BY distance LIMIT 5;

-- Explain
EXPLAIN (ANALYZE, BUFFERS) SELECT ...;

-- List indexes
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'users';
```

---

*[← Previous: Production Checklist](19_Production_Checklist.md) | [Back to Index](README.md)*

---

*PostgreSQL Complete Guide — From SQL Server background to AI-ready vector search*
*Created: 2026-03-24 | Stack: PostgreSQL 16 + pgvector + .NET 10 + EF Core 9*
