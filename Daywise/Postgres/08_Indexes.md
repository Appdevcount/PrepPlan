# 08 — Indexes — Types & When to Use
> Part of: [PostgreSQL Complete Guide](README.md)

---

## 8. Indexes — Types & When to Use

```
┌─────────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: PostgreSQL has 6 index types. SQL Server has 2 (B-tree   │
│  + clustered). Choose the right index type = 10x performance gains.     │
└─────────────────────────────────────────────────────────────────────────┘
```

### Index Types Comparison

| Index Type | Best For | SQL Server Equivalent |
|-----------|---------|----------------------|
| **B-Tree** | =, <, >, BETWEEN, LIKE 'prefix%' | Nonclustered index |
| **Hash** | Only = (equality) | (none) |
| **GIN** | JSONB, Arrays, Full-text search | Full-text index |
| **GiST** | Geometric, Full-text, Range types | Spatial index |
| **BRIN** | Very large tables with natural order (timestamps) | (none) |
| **IVFFlat / HNSW** | Vector similarity search (pgvector) | (none) |

### B-Tree Index (Default)

```sql
-- Single column
CREATE INDEX idx_users_email     ON app.users(email);
CREATE INDEX idx_posts_user_id   ON app.posts(user_id);

-- Composite (order matters — matches most-selective first)
CREATE INDEX idx_posts_user_published ON app.posts(user_id, published);

-- Partial index (only index subset of rows — very efficient)
-- WHY: Only active users are queried 99% of the time
CREATE INDEX idx_users_active_email
    ON app.users(email)
    WHERE is_active = true;

-- Expression index
CREATE INDEX idx_users_email_lower
    ON app.users(LOWER(email));   -- supports: WHERE LOWER(email) = ...

-- CONCURRENTLY — build without table lock
CREATE INDEX CONCURRENTLY idx_posts_created ON app.posts(created_at);
```

### GIN Index (JSONB & Arrays)

```sql
-- Index ALL fields in JSONB column
CREATE INDEX idx_events_payload_gin ON events USING GIN(payload);

-- Specific JSONB path (more targeted)
CREATE INDEX idx_events_type
    ON events USING GIN((payload->'type'));

-- Array index
CREATE INDEX idx_reports_tags ON reports USING GIN(tags);
```

### Full-Text Search Index

```sql
-- Add tsvector column for full-text search
ALTER TABLE app.posts ADD COLUMN search_vector TSVECTOR;

-- Populate with weighted vectors
UPDATE app.posts
SET search_vector =
    setweight(to_tsvector('english', title), 'A') ||    -- title = higher weight
    setweight(to_tsvector('english', COALESCE(body, '')), 'B'); -- body = lower

-- GIN index on the vector
CREATE INDEX idx_posts_search ON app.posts USING GIN(search_vector);

-- Query
SELECT title, ts_rank(search_vector, query) AS rank
FROM   app.posts, to_tsquery('english', 'postgresql & performance') AS query
WHERE  search_vector @@ query
ORDER  BY rank DESC;
```

---

*[← Previous: DML](07_DML.md) | [Back to Index](README.md) | [Next: Advanced Queries →](09_Advanced_Queries.md)*
