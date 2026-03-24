# 09 — Advanced Queries — CTEs, Window Functions, JSONB
> Part of: [PostgreSQL Complete Guide](README.md)

---

## 🎬 Quick Learn

| Format | Video |
|--------|-------|
| **📘 Beginner Course** | [PostgreSQL Full Course — freeCodeCamp · 3 hr](https://www.youtube.com/watch?v=SpfIwlAYaKk) — covers advanced SELECT, GROUP BY, aggregate |
| **🪟 Window Functions** | [SQL Window Functions Tutorial — YouTube Search](https://www.youtube.com/results?search_query=postgresql+window+functions+tutorial+ROW_NUMBER+RANK+LAG) |
| **📋 CTEs** | [PostgreSQL CTEs Common Table Expressions — YouTube Search](https://www.youtube.com/results?search_query=postgresql+CTE+common+table+expression+recursive+writeable+tutorial) |

---

## 9. Advanced Queries — CTEs, Window Functions, JSONB

```
┌─────────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: PostgreSQL's advanced query features are SQL Server's    │
│  equivalents — just better documented and more powerful.                │
└─────────────────────────────────────────────────────────────────────────┘
```

### CTEs (Common Table Expressions)

```sql
-- Standard CTE (same as SQL Server)
WITH active_users AS (
    SELECT id, email
    FROM   app.users
    WHERE  is_active = true
),
post_counts AS (
    SELECT user_id, COUNT(*) AS post_count
    FROM   app.posts
    GROUP  BY user_id
)
SELECT u.email, COALESCE(p.post_count, 0) AS posts
FROM   active_users u
LEFT JOIN post_counts p ON p.user_id = u.id
ORDER BY posts DESC;

-- Writeable CTE (unique to PG — modify data in CTE)
WITH updated AS (
    UPDATE app.users
    SET    is_active = false
    WHERE  created_at < NOW() - INTERVAL '2 years'
    RETURNING id, email
)
INSERT INTO app.audit_log (user_id, action, created_at)
SELECT id, 'deactivated', NOW()
FROM   updated;

-- Recursive CTE (same syntax as SQL Server)
WITH RECURSIVE org_tree AS (
    -- Anchor: top-level managers
    SELECT id, name, manager_id, 0 AS depth
    FROM   employees
    WHERE  manager_id IS NULL

    UNION ALL

    -- Recursive: find subordinates
    SELECT e.id, e.name, e.manager_id, t.depth + 1
    FROM   employees e
    JOIN   org_tree t ON e.manager_id = t.id
)
SELECT * FROM org_tree ORDER BY depth, name;
```

### Window Functions

```sql
-- Running total (same as SQL Server)
SELECT
    created_at::DATE AS day,
    COUNT(*) AS daily_count,
    SUM(COUNT(*)) OVER (ORDER BY created_at::DATE) AS running_total
FROM app.posts
GROUP BY created_at::DATE
ORDER BY day;

-- Rank within partition
SELECT
    user_id,
    title,
    created_at,
    ROW_NUMBER()    OVER (PARTITION BY user_id ORDER BY created_at DESC) AS rn,
    RANK()          OVER (PARTITION BY user_id ORDER BY created_at DESC) AS rnk,
    DENSE_RANK()    OVER (PARTITION BY user_id ORDER BY created_at DESC) AS dense_rnk
FROM app.posts;

-- Get top N per group (latest 3 posts per user)
SELECT user_id, title, created_at
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at DESC) AS rn
    FROM app.posts
) ranked
WHERE rn <= 3;

-- LAG/LEAD (SQL Server compatible syntax)
SELECT
    created_at::DATE AS day,
    COUNT(*) AS cnt,
    LAG(COUNT(*))  OVER (ORDER BY created_at::DATE) AS prev_day,
    LEAD(COUNT(*)) OVER (ORDER BY created_at::DATE) AS next_day
FROM app.posts
GROUP BY created_at::DATE;

-- NTILE — quartiles
SELECT email, score,
       NTILE(4) OVER (ORDER BY score) AS quartile
FROM user_scores;
```

### Advanced JSONB Queries

```sql
-- Nested access
SELECT payload->'address'->>'city' AS city
FROM   customers;

-- JSONB aggregation (build JSON from rows)
SELECT
    user_id,
    JSON_AGG(
        JSON_BUILD_OBJECT('title', title, 'created_at', created_at)
        ORDER BY created_at DESC
    ) AS posts
FROM app.posts
GROUP BY user_id;

-- JSONB update (immutable — must replace entire document or use ||)
UPDATE events
SET    payload = payload || '{"processed": true}'::JSONB
WHERE  id = 1;

-- Remove key
UPDATE events
SET payload = payload - 'temp_field'
WHERE id = 1;

-- JSONB_EACH — expand to rows (like OPENJSON in SQL Server)
SELECT key, value
FROM events, JSONB_EACH(payload)
WHERE id = 1;

-- JSONB path queries (PostgreSQL 12+)
SELECT * FROM events
WHERE payload @? '$.tags[*] ? (@ == "urgent")';
```

---

*[← Previous: Indexes](08_Indexes.md) | [Back to Index](README.md) | [Next: Transactions & Concurrency →](10_Transactions_Concurrency.md)*
