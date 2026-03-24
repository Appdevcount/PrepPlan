# 07 — DML — CRUD with PostgreSQL Flavor
> Part of: [PostgreSQL Complete Guide](README.md)

---

## 7. DML — CRUD with PostgreSQL Flavor

### INSERT

```sql
-- Basic insert
INSERT INTO app.users (email, display_name)
VALUES ('alice@example.com', 'Alice');

-- RETURNING clause (like OUTPUT in SQL Server — but simpler)
-- WHY: Get the generated ID back without a separate SELECT
INSERT INTO app.users (email, display_name)
VALUES ('bob@example.com', 'Bob')
RETURNING id, external_id, created_at;

-- Bulk insert
INSERT INTO app.users (email, display_name)
VALUES
    ('carol@example.com', 'Carol'),
    ('dave@example.com',  'Dave')
RETURNING id;

-- UPSERT (INSERT … ON CONFLICT) — replaces SQL Server MERGE
INSERT INTO app.users (email, display_name)
VALUES ('alice@example.com', 'Alice Updated')
ON CONFLICT (email)
DO UPDATE SET
    display_name = EXCLUDED.display_name,  -- EXCLUDED = the rejected row
    updated_at   = NOW()
RETURNING id;

-- Insert and ignore conflict
INSERT INTO app.users (email, display_name)
VALUES ('alice@example.com', 'Alice')
ON CONFLICT (email) DO NOTHING;
```

### SELECT

```sql
-- Basic
SELECT id, email, display_name
FROM   app.users
WHERE  is_active = true
ORDER  BY created_at DESC
LIMIT  10 OFFSET 20;   -- pagination (SQL Server: OFFSET 20 ROWS FETCH NEXT 10)

-- DISTINCT ON (no SQL Server equivalent — very useful)
-- WHY: Get the latest post per user in one query
SELECT DISTINCT ON (user_id)
    user_id, title, created_at
FROM app.posts
ORDER BY user_id, created_at DESC;

-- NULLS LAST (SQL Server requires CASE workaround)
SELECT * FROM app.users ORDER BY phone NULLS LAST;

-- FILTER clause in aggregates
SELECT
    COUNT(*) FILTER (WHERE is_active = true)  AS active_count,
    COUNT(*) FILTER (WHERE is_active = false) AS inactive_count,
    COUNT(*)                                  AS total
FROM app.users;
```

### UPDATE

```sql
-- Basic
UPDATE app.users
SET    display_name = 'Alice Smith', updated_at = NOW()
WHERE  email = 'alice@example.com'
RETURNING id, display_name;

-- UPDATE with JOIN (FROM clause — different from SQL Server syntax)
-- SQL Server: UPDATE u SET ... FROM users u JOIN posts p ON ...
-- PostgreSQL:
UPDATE app.users u
SET    is_active = false
FROM   app.posts p
WHERE  p.user_id = u.id
AND    p.published = false
AND    u.created_at < NOW() - INTERVAL '1 year'
RETURNING u.id, u.email;
```

### DELETE

```sql
-- Basic
DELETE FROM app.users WHERE id = 42 RETURNING id, email;

-- DELETE with subquery
DELETE FROM app.posts
WHERE user_id IN (
    SELECT id FROM app.users WHERE is_active = false
);

-- TRUNCATE (fast delete all rows — same as SQL Server)
TRUNCATE TABLE app.posts RESTART IDENTITY CASCADE;
-- RESTART IDENTITY resets IDENTITY sequence
-- CASCADE truncates dependent tables too
```

### COPY — Bulk Load (Like BULK INSERT in SQL Server)

```sql
-- Import CSV
COPY app.users (email, display_name)
FROM '/tmp/users.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Export CSV
COPY (SELECT id, email FROM app.users WHERE is_active = true)
TO '/tmp/active_users.csv'
WITH (FORMAT csv, HEADER true);
```

---

*[← Previous: DDL](06_DDL.md) | [Back to Index](README.md) | [Next: Indexes →](08_Indexes.md)*
