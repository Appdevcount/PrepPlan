# PostgreSQL — Complete Guide: Beginner to Expert + AI Vector DB
> From SQL Server background → PostgreSQL mastery → pgvector for AI workloads
> Mental Model: PostgreSQL is SQL Server's open-source cousin — same relational DNA, different dialect, supercharged extensions

---

## Table of Contents

1. [Why PostgreSQL? — Advantages Over SQL Server](#1-why-postgresql--advantages-over-sql-server)
2. [Core Concepts — SQL Server vs PostgreSQL Mapping](#2-core-concepts--sql-server-vs-postgresql-mapping)
3. [Installation & Setup (Local + Docker)](#3-installation--setup-local--docker)
4. [PostgreSQL Architecture Deep Dive](#4-postgresql-architecture-deep-dive)
5. [Data Types — Full Reference](#5-data-types--full-reference)
6. [DDL — Tables, Schemas, Constraints](#6-ddl--tables-schemas-constraints)
7. [DML — CRUD with PostgreSQL Flavor](#7-dml--crud-with-postgresql-flavor)
8. [Indexes — Types & When to Use](#8-indexes--types--when-to-use)
9. [Advanced Queries — CTEs, Window Functions, JSONB](#9-advanced-queries--ctes-window-functions-jsonb)
10. [Transactions & Concurrency (MVCC)](#10-transactions--concurrency-mvcc)
11. [Stored Procedures, Functions & Triggers](#11-stored-procedures-functions--triggers)
12. [Performance Tuning & EXPLAIN ANALYZE](#12-performance-tuning--explain-analyze)
13. [Replication & High Availability](#13-replication--high-availability)
14. [Security — Roles, RLS, Encryption](#14-security--roles-rls-encryption)
15. [PostgreSQL Extensions Ecosystem](#15-postgresql-extensions-ecosystem)
16. [pgvector — AI Vector Database (Complete)](#16-pgvector--ai-vector-database-complete)
17. [PostgreSQL with .NET / EF Core](#17-postgresql-with-net--ef-core)
18. [PostgreSQL on Azure (Flexible Server)](#18-postgresql-on-azure-flexible-server)
19. [Production Checklist & Monitoring](#19-production-checklist--monitoring)
20. [Interview Q&A — 30 Expert Questions](#20-interview-qa--30-expert-questions)

---

## 1. Why PostgreSQL? — Advantages Over SQL Server

```
┌─────────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: PostgreSQL is a Swiss Army knife.                        │
│  SQL Server is a premium steak knife — excellent at one thing.          │
│  PostgreSQL handles relational, JSON, time-series, geospatial, AND      │
│  vectors — all in one engine.                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

### Advantages Over SQL Server

| Dimension | SQL Server | PostgreSQL | Winner |
|-----------|-----------|------------|--------|
| **License** | Commercial ($$$) | Open Source (free forever) | PG |
| **Cost at scale** | Very high | $0 license | PG |
| **Platform** | Windows-first | Linux-native (also Windows/Mac) | PG |
| **JSON support** | JSON (basic) | JSONB (binary, indexed, fast) | PG |
| **Extensions** | Limited | 1000+ extensions (pgvector, PostGIS, TimescaleDB…) | PG |
| **Vector/AI** | No native support | pgvector (native similarity search) | PG |
| **Geospatial** | Basic geography | PostGIS (industry standard) | PG |
| **Full-text search** | OK | Excellent (tsvector, GIN indexes) | PG |
| **ACID compliance** | Yes | Yes | Tie |
| **Stored procedures** | T-SQL | PL/pgSQL + Python/JS/Perl | PG |
| **Window functions** | Yes | Yes + more | PG |
| **Cloud managed** | Azure SQL | Azure PostgreSQL Flexible, RDS, Cloud SQL, Supabase | PG |
| **Active community** | Microsoft only | Worldwide open community | PG |
| **EXPLAIN output** | Moderate | Best in class (EXPLAIN ANALYZE BUFFERS) | PG |
| **Tooling** | SSMS | pgAdmin, DBeaver, psql, DataGrip | Tie |
| **CTEs** | Yes | Yes + writeable CTEs | PG |
| **UPSERT** | MERGE | INSERT … ON CONFLICT (simpler) | PG |

### Why PostgreSQL for AI / Vector Search?

```
Without vector DB:          With pgvector (PostgreSQL):
──────────────────          ──────────────────────────────
Embeddings in code          Embeddings stored IN the DB
Separate Pinecone/Chroma    No extra service to manage
Two systems to sync         Single ACID-compliant system
No SQL joins on vectors     JOIN vectors with business data
Complex infra               Simple: one Postgres + pgvector
```

---

## 2. Core Concepts — SQL Server vs PostgreSQL Mapping

```
┌─────────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Think of PostgreSQL like SQL Server but with different   │
│  terminology and a few extra superpowers.                               │
└─────────────────────────────────────────────────────────────────────────┘
```

### Terminology Mapping

| SQL Server Concept | PostgreSQL Equivalent | Notes |
|-------------------|----------------------|-------|
| Instance | Cluster / Server | One Postgres process = one cluster |
| Database | Database | Same concept |
| Schema | Schema | PG default schema is `public` |
| dbo | public | Default schema name differs |
| Table | Table | Same |
| Stored Procedure | Function / Procedure | PG has both since v11 |
| Identity column | SERIAL / GENERATED ALWAYS AS IDENTITY | PG preferred: IDENTITY |
| NVARCHAR(MAX) | TEXT | TEXT is unlimited in PG |
| NVARCHAR(n) | VARCHAR(n) | Same behavior |
| BIT | BOOLEAN | `true`/`false` not 1/0 |
| DATETIME2 | TIMESTAMPTZ | Always use TIMESTAMPTZ in PG |
| UNIQUEIDENTIFIER | UUID | Use `gen_random_uuid()` |
| XML | XML | Same name, different query |
| JSON | JSONB | JSONB = binary, indexed, fast |
| ROWVERSION | xmin (system column) | Optimistic concurrency |
| @@ROWCOUNT | GET DIAGNOSTICS | Different syntax |
| TOP(n) | LIMIT n | Standard SQL |
| ISNULL() | COALESCE() | COALESCE is standard SQL |
| LEN() | LENGTH() | Standard SQL |
| GETDATE() | NOW() / CURRENT_TIMESTAMP | |
| NEWID() | gen_random_uuid() | PG 13+ built-in |
| GO | ; | Statement separator |
| BEGIN…END | BEGIN…END | Same in PL/pgSQL |
| TRY…CATCH | BEGIN…EXCEPTION | Different syntax |
| MERGE | INSERT…ON CONFLICT | PG is simpler |
| sp_executesql | EXECUTE / $$ | Dynamic SQL |
| sys.tables | information_schema.tables | ANSI standard |
| SQL Agent | pg_cron extension | External scheduler |

### Connection Strings Comparison

```sql
-- SQL Server (C#)
"Server=localhost;Database=mydb;User Id=sa;Password=xxx;"

-- PostgreSQL (C#)
"Host=localhost;Database=mydb;Username=postgres;Password=xxx;"
-- OR the classic URI format:
"postgresql://postgres:xxx@localhost:5432/mydb"
```

---

## 3. Installation & Setup (Local + Docker)

### Option A — Docker (Recommended for Dev)

```yaml
# docker-compose.yml
version: '3.9'
services:
  postgres:
    image: pgvector/pgvector:pg16   # includes pgvector extension
    container_name: postgres_dev
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: devdb
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  pgadmin:                          # Web UI like SSMS
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@admin.com
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "5050:80"
    depends_on:
      - postgres

volumes:
  postgres_data:
```

```bash
# Start
docker-compose up -d

# Connect via psql inside container
docker exec -it postgres_dev psql -U postgres -d devdb

# OR connect from host (install psql client)
psql -h localhost -U postgres -d devdb
```

### Option B — Windows Local Install

```
1. Download from https://www.postgresql.org/download/windows/
2. Use the installer (EnterpriseDB)
3. Default port: 5432
4. pgAdmin is included in the installer
5. Add C:\Program Files\PostgreSQL\16\bin to PATH
```

### psql — The Command Line Tool (like sqlcmd)

```bash
# Connect
psql -h localhost -U postgres -d mydb

# psql meta-commands (start with \)
\l              -- list databases  (like: SELECT name FROM sys.databases)
\c mydb         -- connect to database
\dt             -- list tables in current schema
\dt public.*    -- list all tables in public schema
\d tablename    -- describe table (like sp_help)
\dn             -- list schemas
\df             -- list functions
\du             -- list users/roles
\timing         -- toggle query timing
\x              -- expanded output (vertical like SQL Server \G)
\i file.sql     -- execute SQL file
\q              -- quit
\?              -- help for meta-commands
\h SELECT       -- help for SQL command
```

### pgAdmin (Web UI — like SSMS)

```
URL: http://localhost:5050
Login: admin@admin.com / admin
Add Server:
  - Name: Local Dev
  - Host: postgres (docker) or localhost
  - Port: 5432
  - Username: postgres
  - Password: postgres
```

---

## 4. PostgreSQL Architecture Deep Dive

```
┌─────────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: PostgreSQL is like a city.                               │
│  - The postmaster process is the mayor (accepts all connections)        │
│  - Each client connection gets its own worker process (not thread)      │
│  - Shared memory (shared_buffers) is the town square everyone uses      │
│  - WAL (Write-Ahead Log) is the city's official record book             │
└─────────────────────────────────────────────────────────────────────────┘
```

```
┌──────────────────── PostgreSQL Architecture ────────────────────────────┐
│                                                                         │
│   Client App (.NET / psql)                                              │
│        │                                                                │
│   ┌────▼────────────────────────────────────────────────────┐          │
│   │  Postmaster (listener on :5432)                         │          │
│   │  Forks a backend process per connection                 │          │
│   └────┬────────────────────────────────────────────────────┘          │
│        │                                                                │
│   ┌────▼─────────────────────────────────────────────────────────────┐ │
│   │  Backend Process (per connection)                                │ │
│   │  Parse → Analyze → Rewrite → Plan → Execute                     │ │
│   └────┬──────────────────────────────┬───────────────────────────── │ │
│        │                              │                               │ │
│   ┌────▼──────────┐          ┌────────▼──────────────────────┐       │ │
│   │  Shared Memory│          │  Storage (Data Files)         │       │ │
│   │  shared_buffers│         │  Base/ (heap files)           │       │ │
│   │  WAL buffers  │          │  pg_wal/ (transaction log)    │       │ │
│   │  lock tables  │          │  pg_stat/ (stats)             │       │ │
│   └───────────────┘          └───────────────────────────────┘       │ │
│                                                                         │
│  Background Workers:                                                    │
│   • Checkpointer   — flushes dirty pages to disk                       │
│   • WAL writer     — flushes WAL buffer to WAL files                   │
│   • Autovacuum     — reclaims dead tuple space (NO EQUIVALENT in MSSQL)│
│   • Stats collector— tracks table/index usage                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Key Difference: MVCC vs SQL Server's Lock Manager

```
SQL Server:             PostgreSQL:
─────────────────────   ─────────────────────────────────────────
Readers block writers   Readers NEVER block writers (MVCC)
Writers block readers   Writers NEVER block readers
Row-level locking       Row versions (old rows kept until VACUUM)
TempDB for versions     Heap table stores old versions inline
```

**MVCC (Multi-Version Concurrency Control):**
- Every row has `xmin` (created by transaction) and `xmax` (deleted by transaction)
- Readers see a snapshot of the DB at their transaction start
- Old versions accumulate → **VACUUM** reclaims them (autovacuum runs automatically)

---

## 5. Data Types — Full Reference

```
┌─────────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: PG types are richer than SQL Server.                     │
│  "When in doubt, use TEXT for strings, TIMESTAMPTZ for dates,           │
│   BIGINT for IDs, NUMERIC for money, JSONB for semi-structured data"    │
└─────────────────────────────────────────────────────────────────────────┘
```

### Numeric Types

```sql
SMALLINT        -- -32,768 to 32,767         (SQL Server: SMALLINT)
INTEGER / INT   -- -2B to 2B                 (SQL Server: INT)
BIGINT          -- -9 quintillion to 9Q      (SQL Server: BIGINT)
NUMERIC(p,s)    -- exact decimal             (SQL Server: DECIMAL)
DECIMAL(p,s)    -- alias for NUMERIC
REAL            -- 4-byte float              (SQL Server: REAL)
DOUBLE PRECISION-- 8-byte float              (SQL Server: FLOAT)
SERIAL          -- auto-increment INT        (legacy, prefer IDENTITY)
BIGSERIAL       -- auto-increment BIGINT     (legacy)

-- PREFERRED modern syntax:
id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY
id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY
```

### Text Types

```sql
CHAR(n)         -- fixed-length, padded      (SQL Server: CHAR)
VARCHAR(n)      -- variable, max n chars     (SQL Server: NVARCHAR(n))
TEXT            -- unlimited length          (SQL Server: NVARCHAR(MAX))

-- KEY INSIGHT: In PostgreSQL, VARCHAR(n) and TEXT have same performance.
-- Use TEXT unless you need the length constraint as a business rule.
-- PostgreSQL stores all strings as UTF-8 natively — no N prefix needed.
```

### Date/Time Types

```sql
DATE            -- date only (no time)
TIME            -- time only (no date)
TIMESTAMP       -- date + time, NO timezone  ← AVOID: ambiguous
TIMESTAMPTZ     -- date + time WITH timezone ← ALWAYS USE THIS
INTERVAL        -- duration ('2 hours', '3 days')

-- KEY INSIGHT: TIMESTAMPTZ stores in UTC internally, converts on output.
-- SQL Server equivalent: DATETIMEOFFSET

-- Examples:
SELECT NOW();                    -- current timestamp with TZ
SELECT CURRENT_DATE;             -- today's date
SELECT NOW() + INTERVAL '7 days'; -- one week from now
```

### Boolean & UUID

```sql
BOOLEAN         -- true / false / null  (SQL Server: BIT = 1/0)
UUID            -- 128-bit UUID         (SQL Server: UNIQUEIDENTIFIER)

-- Generate UUID:
SELECT gen_random_uuid();  -- PostgreSQL 13+  (like NEWID() in SQL Server)
```

### JSONB — The Killer Feature

```sql
-- JSON  = stored as text, re-parsed each query  (slow)
-- JSONB = stored as binary, indexed            (fast, USE THIS)

CREATE TABLE events (
    id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    payload JSONB NOT NULL
);

-- Insert
INSERT INTO events (payload)
VALUES ('{"type": "UserCreated", "userId": 42, "tags": ["admin","active"]}');

-- Query JSONB fields
SELECT payload->>'type'         AS event_type,    -- text value
       payload->'userId'        AS user_id_json,   -- JSON value
       (payload->>'userId')::INT AS user_id_int    -- cast to INT
FROM   events
WHERE  payload->>'type' = 'UserCreated';           -- filter by JSONB field

-- Array operations
SELECT * FROM events
WHERE  payload->'tags' ? 'admin';                  -- contains element

-- GIN index for JSONB (makes all field queries fast)
CREATE INDEX idx_events_payload ON events USING GIN(payload);
```

### Arrays — Native Arrays (No SQL Server Equivalent)

```sql
-- PostgreSQL supports arrays of any type natively
CREATE TABLE reports (
    id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tags    TEXT[],
    scores  INTEGER[]
);

INSERT INTO reports (tags, scores)
VALUES (ARRAY['billing','urgent'], ARRAY[85, 92, 78]);

-- Query array
SELECT * FROM reports WHERE 'urgent' = ANY(tags);
SELECT tags[1] FROM reports;   -- 1-indexed!
SELECT array_length(scores, 1) FROM reports;
```

### Special Types

```sql
BYTEA           -- binary data            (SQL Server: VARBINARY)
INET            -- IP address (with CIDR logic)
CIDR            -- IP network
MACADDR         -- MAC address
TSVECTOR        -- full-text search document
TSQUERY         -- full-text search query
POINT/LINE/POLYGON -- geometric types
MONEY           -- currency (use NUMERIC instead for precision)
```

---

## 6. DDL — Tables, Schemas, Constraints

### Creating Tables

```sql
-- ── Schema Setup ────────────────────────────────────────────────
CREATE SCHEMA app;         -- like a namespace (SQL Server: CREATE SCHEMA)
SET search_path TO app, public;  -- default schema lookup path

-- ── Primary Table Pattern ────────────────────────────────────────
CREATE TABLE app.users (
    -- WHY GENERATED ALWAYS: prevents accidental manual inserts into ID
    id              BIGINT          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    -- WHY UUID: for distributed systems where INT IDs can collide
    external_id     UUID            NOT NULL DEFAULT gen_random_uuid(),
    email           TEXT            NOT NULL,
    display_name    TEXT            NOT NULL,
    role            TEXT            NOT NULL DEFAULT 'user',
    is_active       BOOLEAN         NOT NULL DEFAULT true,
    metadata        JSONB           NOT NULL DEFAULT '{}',
    -- WHY TIMESTAMPTZ: always store with timezone to avoid DST bugs
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT uq_users_email       UNIQUE (email),
    CONSTRAINT uq_users_external_id UNIQUE (external_id),
    CONSTRAINT chk_users_role       CHECK (role IN ('user','admin','moderator'))
);

-- ── Foreign Key Example ──────────────────────────────────────────
CREATE TABLE app.posts (
    id          BIGINT  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id     BIGINT  NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    title       TEXT    NOT NULL,
    body        TEXT,
    published   BOOLEAN NOT NULL DEFAULT false,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Auto-Update updated_at (Trigger)

```sql
-- WHY: SQL Server has no equivalent — you'd use a default + manual UPDATE
-- In PG, triggers handle this elegantly

CREATE OR REPLACE FUNCTION app.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON app.users
    FOR EACH ROW
    EXECUTE FUNCTION app.set_updated_at();
```

### ALTER TABLE

```sql
-- Add column
ALTER TABLE app.users ADD COLUMN phone TEXT;

-- Add NOT NULL with default (safe pattern — avoids table lock on large tables)
ALTER TABLE app.users ADD COLUMN tier TEXT NOT NULL DEFAULT 'free';

-- Drop column
ALTER TABLE app.users DROP COLUMN phone;

-- Rename column
ALTER TABLE app.users RENAME COLUMN display_name TO full_name;

-- Change type (careful: may require USING clause)
ALTER TABLE app.users ALTER COLUMN tier TYPE VARCHAR(50);

-- Add index
CREATE INDEX CONCURRENTLY idx_users_email ON app.users(email);
-- WHY CONCURRENTLY: allows index creation without locking the table
```

### ENUM Types

```sql
-- WHY: Strong typing for status fields (better than CHECK constraints for readability)
CREATE TYPE app.user_status AS ENUM ('pending', 'active', 'suspended', 'deleted');

ALTER TABLE app.users ADD COLUMN status app.user_status NOT NULL DEFAULT 'pending';

-- Add a value to existing enum (additive only — can't remove or rename)
ALTER TYPE app.user_status ADD VALUE 'verified' AFTER 'pending';
```

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

## 10. Transactions & Concurrency (MVCC)

```
┌─────────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: PostgreSQL transactions are like SQL Server transactions  │
│  but readers and writers don't block each other (MVCC magic).           │
└─────────────────────────────────────────────────────────────────────────┘
```

### Transaction Isolation Levels

| Level | Dirty Read | Non-Repeatable Read | Phantom Read | PG Default? |
|-------|-----------|--------------------|--------------|----|
| READ UNCOMMITTED | ✓ possible | ✓ possible | ✓ possible | ✗ (maps to READ COMMITTED) |
| READ COMMITTED | ✗ | ✓ possible | ✓ possible | **YES** |
| REPEATABLE READ | ✗ | ✗ | ✗ in PG* | ✗ |
| SERIALIZABLE | ✗ | ✗ | ✗ | ✗ |

*PG REPEATABLE READ also prevents phantoms (stronger than SQL standard)

```sql
-- Begin transaction with isolation level
BEGIN;
-- or:
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Savepoint (like SQL Server SAVE TRANSACTION)
SAVEPOINT my_savepoint;
-- ... do work ...
ROLLBACK TO SAVEPOINT my_savepoint;  -- partial rollback
RELEASE SAVEPOINT my_savepoint;      -- commit savepoint
COMMIT;

-- Advisory locks (application-level distributed locks)
-- WHY: Coordinate distributed operations without touching business tables
SELECT pg_advisory_lock(42);        -- session lock (blocks)
SELECT pg_try_advisory_lock(42);    -- non-blocking, returns bool
SELECT pg_advisory_unlock(42);
```

### Locking

```sql
-- SELECT FOR UPDATE (like SQL Server UPDLOCK hint)
-- WHY: Lock selected rows to prevent concurrent updates
BEGIN;
SELECT * FROM app.users WHERE id = 1 FOR UPDATE;
UPDATE app.users SET is_active = false WHERE id = 1;
COMMIT;

-- SKIP LOCKED (process queues without contention)
-- WHY: Multiple workers can process queue items without blocking each other
SELECT id, payload
FROM   job_queue
WHERE  status = 'pending'
ORDER  BY created_at
LIMIT  1
FOR UPDATE SKIP LOCKED;

-- NOWAIT (fail immediately if locked — SQL Server: NOWAIT hint)
SELECT * FROM app.users WHERE id = 1 FOR UPDATE NOWAIT;
```

---

## 11. Stored Procedures, Functions & Triggers

```
┌─────────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: PG has FUNCTIONS (return values) and PROCEDURES          │
│  (no return, call with CALL). SQL Server's T-SQL → PL/pgSQL.            │
└─────────────────────────────────────────────────────────────────────────┘
```

### PL/pgSQL Functions (equivalent to T-SQL functions/procs)

```sql
-- ── Simple Function ──────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION app.get_user_post_count(p_user_id BIGINT)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM   app.posts
    WHERE  user_id = p_user_id;

    RETURN v_count;
END;
$$;

-- Call
SELECT app.get_user_post_count(42);

-- ── Function Returning TABLE (like SQL Server TVF) ───────────────────
CREATE OR REPLACE FUNCTION app.get_active_users_paged(
    p_page      INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 20
)
RETURNS TABLE(id BIGINT, email TEXT, display_name TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.email, u.display_name
    FROM   app.users u
    WHERE  u.is_active = true
    ORDER  BY u.created_at DESC
    LIMIT  p_page_size
    OFFSET (p_page - 1) * p_page_size;
END;
$$;

-- Call like a table
SELECT * FROM app.get_active_users_paged(page => 2, p_page_size => 10);

-- ── Procedure with Transaction Control (PostgreSQL 11+) ──────────────
CREATE OR REPLACE PROCEDURE app.deactivate_old_users(
    p_days_inactive INTEGER DEFAULT 365
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    UPDATE app.users
    SET    is_active = false
    WHERE  updated_at < NOW() - (p_days_inactive || ' days')::INTERVAL
    AND    is_active = true;

    GET DIAGNOSTICS v_count = ROW_COUNT;
    RAISE NOTICE 'Deactivated % users', v_count;

    COMMIT;  -- Procedures can commit/rollback (functions cannot)
END;
$$;

-- Call
CALL app.deactivate_old_users(180);

-- ── Error Handling ───────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION app.safe_divide(a NUMERIC, b NUMERIC)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    IF b = 0 THEN
        RAISE EXCEPTION 'Division by zero: b cannot be 0'
            USING ERRCODE = 'division_by_zero',
                  HINT    = 'Check the divisor value';
    END IF;
    RETURN a / b;
EXCEPTION
    WHEN division_by_zero THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE;   -- re-raise unknown exceptions
END;
$$;
```

### Triggers

```sql
-- ── Audit Log Trigger ────────────────────────────────────────────────
CREATE TABLE app.audit_log (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_name  TEXT NOT NULL,
    operation   TEXT NOT NULL,
    old_data    JSONB,
    new_data    JSONB,
    changed_by  TEXT DEFAULT current_user,
    changed_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION app.audit_trigger_fn()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO app.audit_log (table_name, operation, old_data, new_data)
    VALUES (
        TG_TABLE_NAME,
        TG_OP,
        CASE WHEN TG_OP = 'DELETE' THEN ROW_TO_JSON(OLD)::JSONB ELSE NULL END,
        CASE WHEN TG_OP != 'DELETE' THEN ROW_TO_JSON(NEW)::JSONB ELSE NULL END
    );
    RETURN NEW;
END;
$$;

-- Attach to table
CREATE TRIGGER trg_users_audit
    AFTER INSERT OR UPDATE OR DELETE ON app.users
    FOR EACH ROW EXECUTE FUNCTION app.audit_trigger_fn();
```

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

## 14. Security — Roles, RLS, Encryption

```
┌─────────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: PostgreSQL roles = SQL Server logins + database users.   │
│  Row-Level Security (RLS) = SQL Server Row-Level Security.              │
│  Both are great — PostgreSQL RLS syntax is simpler.                     │
└─────────────────────────────────────────────────────────────────────────┘
```

### Roles & Permissions

```sql
-- Create roles (SQL Server: CREATE LOGIN + CREATE USER)
CREATE ROLE app_readonly;
CREATE ROLE app_readwrite;

CREATE USER api_service WITH PASSWORD 'secure_password_here';
GRANT app_readwrite TO api_service;

-- Grant schema permissions
GRANT USAGE ON SCHEMA app TO app_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA app TO app_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA app
    GRANT SELECT ON TABLES TO app_readonly;  -- WHY: covers future tables too

GRANT USAGE ON SCHEMA app TO app_readwrite;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app TO app_readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA app
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_readwrite;

-- Revoke public access (security hardening)
REVOKE ALL ON SCHEMA public FROM PUBLIC;
```

### Row-Level Security (RLS)

```sql
-- Enable RLS on table
ALTER TABLE app.posts ENABLE ROW LEVEL SECURITY;

-- Policy: users can only see their own posts
CREATE POLICY posts_user_isolation ON app.posts
    USING (user_id = current_setting('app.current_user_id')::BIGINT);

-- Policy: admins see everything
CREATE POLICY posts_admin_all ON app.posts
    TO admin_role
    USING (true);

-- In application: set user context before queries
SET app.current_user_id = '42';
SELECT * FROM app.posts;  -- automatically filtered to user 42's posts
```

### Encryption

```sql
-- Encrypt column data with pgcrypto extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Store encrypted data
INSERT INTO app.sensitive_data (user_id, ssn_encrypted)
VALUES (1, pgp_sym_encrypt('123-45-6789', 'encryption_key'));

-- Decrypt
SELECT pgp_sym_decrypt(ssn_encrypted::BYTEA, 'encryption_key') AS ssn
FROM   app.sensitive_data
WHERE  user_id = 1;

-- Hash passwords (use in app layer with BCrypt instead — this is for demonstration)
SELECT crypt('user_password', gen_salt('bf', 8)) AS hashed;
SELECT crypt('user_password', stored_hash) = stored_hash AS is_valid;
```

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

## 16. pgvector — AI Vector Database (Complete)

```
┌─────────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Think of vectors as GPS coordinates for meaning.         │
│  "PostgreSQL + machine learning" = you can store the GPS coords         │
│  right next to your business data, and query both together with SQL.    │
│                                                                         │
│  Traditional search: "find rows WHERE title LIKE '%banking%'"           │
│  Vector search:      "find rows WHERE meaning SIMILAR TO 'banking'"     │
│                      → also finds 'finance', 'loans', 'credit'         │
└─────────────────────────────────────────────────────────────────────────┘
```

### What Are Vectors / Embeddings?

```
Text → Embedding Model → Vector (array of floats)

"The cat sat on the mat" → OpenAI text-embedding-3-small → [0.023, -0.145, 0.872, ...]
                                                             ↑ 1536 dimensions

Similar sentences → similar vectors → small distance between them
Different topics  → different vectors → large distance between them

Distance Metrics:
─────────────────────────────────────────────────────
L2 (Euclidean)    <->   : absolute spatial distance
Cosine similarity  <>   : angle between vectors (text/semantic)
Inner product      <#>  : dot product (normalized vectors)
```

### Setup pgvector

```sql
-- Enable extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Verify
SELECT * FROM pg_extension WHERE extname = 'vector';
```

### Schema Design for Vector Search

```sql
-- ── Document Store with Embeddings ──────────────────────────────────
CREATE TABLE ai.documents (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_url      TEXT,
    title           TEXT NOT NULL,
    content         TEXT NOT NULL,
    -- WHY vector(1536): OpenAI text-embedding-3-small dimension count
    -- For text-embedding-3-large: vector(3072)
    -- For Ada v2: vector(1536)
    -- For Nomic embed: vector(768)
    embedding       vector(1536),
    metadata        JSONB NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Chat Message Store ───────────────────────────────────────────────
CREATE TABLE ai.messages (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    session_id  UUID NOT NULL,
    role        TEXT NOT NULL CHECK (role IN ('user','assistant','system')),
    content     TEXT NOT NULL,
    embedding   vector(1536),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Product Catalog with Semantic Search ─────────────────────────────
CREATE TABLE ai.products (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku         TEXT NOT NULL UNIQUE,
    name        TEXT NOT NULL,
    description TEXT,
    category    TEXT,
    price       NUMERIC(10,2),
    embedding   vector(1536),    -- semantic embedding of name+description
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Vector Indexes

```sql
-- ── IVFFlat Index (approximate, faster to build) ─────────────────────
-- WHY: Use when table has > 100K rows
-- Rule: lists = rows / 1000 (min 100)
CREATE INDEX idx_documents_embedding_ivfflat
    ON ai.documents
    USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);
-- vector_cosine_ops  = cosine distance (best for text embeddings)
-- vector_l2_ops      = L2 distance (Euclidean)
-- vector_ip_ops      = inner product (for normalized vectors)

-- ── HNSW Index (approximate, faster queries, more memory) ────────────
-- WHY: Use for production — better recall than IVFFlat, faster queries
-- Available in pgvector 0.5.0+
CREATE INDEX idx_documents_embedding_hnsw
    ON ai.documents
    USING hnsw (embedding vector_cosine_ops)
    WITH (m = 16, ef_construction = 64);
-- m = number of bi-directional links per node (16-64)
-- ef_construction = size of dynamic candidate list during build (64-200)

-- Set probes for IVFFlat queries (more = better recall, slower)
SET ivfflat.probes = 10;

-- Set ef_search for HNSW queries (more = better recall, slower)
SET hnsw.ef_search = 100;
```

### Similarity Search Queries

```sql
-- ── Cosine Similarity Search ─────────────────────────────────────────
-- Find 5 most semantically similar documents to a query vector
SELECT
    id,
    title,
    content,
    1 - (embedding <=> '[0.1, 0.2, ...]'::vector) AS cosine_similarity
FROM ai.documents
ORDER BY embedding <=> '[0.1, 0.2, ...]'::vector  -- <=> = cosine distance
LIMIT 5;

-- ── L2 Distance Search ───────────────────────────────────────────────
SELECT id, title,
       embedding <-> '[0.1, 0.2, ...]'::vector AS l2_distance
FROM   ai.documents
ORDER  BY embedding <-> '[0.1, 0.2, ...]'::vector  -- <-> = L2 distance
LIMIT  5;

-- ── Hybrid Search (Vector + Keyword + Filters) ───────────────────────
-- WHY: Pure vector search can miss exact keyword matches; hybrid wins
WITH semantic_search AS (
    SELECT id, RANK() OVER (ORDER BY embedding <=> $1) AS vector_rank
    FROM   ai.documents
    WHERE  metadata->>'category' = 'technical'   -- metadata filter
    ORDER  BY embedding <=> $1
    LIMIT  20
),
keyword_search AS (
    SELECT id, RANK() OVER (ORDER BY ts_rank(search_vector, to_tsquery('english', $2))) AS text_rank
    FROM   ai.documents
    WHERE  search_vector @@ to_tsquery('english', $2)
    LIMIT  20
)
-- Reciprocal Rank Fusion (RRF) scoring
SELECT
    d.id, d.title, d.content,
    COALESCE(1.0 / (60 + s.vector_rank), 0) +
    COALESCE(1.0 / (60 + k.text_rank), 0) AS rrf_score
FROM ai.documents d
LEFT JOIN semantic_search s ON s.id = d.id
LEFT JOIN keyword_search   k ON k.id = d.id
WHERE s.id IS NOT NULL OR k.id IS NOT NULL
ORDER BY rrf_score DESC
LIMIT 10;

-- ── Similarity Threshold (only return close matches) ─────────────────
SELECT id, title,
       1 - (embedding <=> $1::vector) AS similarity
FROM   ai.documents
WHERE  1 - (embedding <=> $1::vector) > 0.75   -- only > 75% similar
ORDER  BY similarity DESC
LIMIT  10;
```

### RAG (Retrieval-Augmented Generation) Pattern

```
┌─────────────────────────────────────────────────────────────────────────┐
│  RAG Architecture with pgvector:                                        │
│                                                                         │
│  User Query                                                             │
│      │                                                                  │
│      ▼                                                                  │
│  Embedding Model (OpenAI / HuggingFace)                                 │
│      │ query_vector                                                     │
│      ▼                                                                  │
│  pgvector: SELECT ... ORDER BY embedding <=> query_vector LIMIT 5       │
│      │ top_k_chunks                                                     │
│      ▼                                                                  │
│  Build Prompt: system + context_chunks + user_query                     │
│      │                                                                  │
│      ▼                                                                  │
│  LLM (GPT-4 / Claude / Llama) → Answer                                 │
└─────────────────────────────────────────────────────────────────────────┘
```

### Full RAG Implementation in C# with pgvector

```csharp
// ── NuGet packages needed ────────────────────────────────────────────
// Npgsql.EntityFrameworkCore.PostgreSQL
// Pgvector.EntityFrameworkCore
// Azure.AI.OpenAI  (or OpenAI)

// ── EF Core Entity ───────────────────────────────────────────────────
using Pgvector;

public record DocumentChunk
{
    public long     Id          { get; init; }
    public string   Title       { get; init; } = "";
    public string   Content     { get; init; } = "";
    public Vector   Embedding   { get; init; } = null!;   // pgvector type
    public string   SourceUrl   { get; init; } = "";
    public DateTime CreatedAt   { get; init; }
}

// ── DbContext ────────────────────────────────────────────────────────
public class AiDbContext : DbContext
{
    public DbSet<DocumentChunk> Documents { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // WHY: register pgvector extension with EF Core
        modelBuilder.HasPostgresExtension("vector");

        modelBuilder.Entity<DocumentChunk>(e =>
        {
            e.ToTable("documents", "ai");
            e.HasKey(x => x.Id);

            // WHY: map the Vector type to pgvector column
            e.Property(x => x.Embedding)
             .HasColumnType("vector(1536)");

            // HNSW index via EF Core migrations
            e.HasIndex(x => x.Embedding)
             .HasMethod("hnsw")
             .HasOperators("vector_cosine_ops")
             .HasStorageParameter("m", 16)
             .HasStorageParameter("ef_construction", 64);
        });
    }
}

// ── Embedding Service ─────────────────────────────────────────────────
public class EmbeddingService(OpenAIClient openAiClient)
{
    private const string Model = "text-embedding-3-small";

    public async Task<float[]> GetEmbeddingAsync(string text,
        CancellationToken ct = default)
    {
        var response = await openAiClient.GetEmbeddingsAsync(
            new EmbeddingsOptions(Model, [text]), ct);

        // WHY: normalize to unit vector for cosine similarity
        return response.Value.Data[0].Embedding.ToArray();
    }
}

// ── RAG Service ───────────────────────────────────────────────────────
public class RagService(AiDbContext db, EmbeddingService embedder,
    OpenAIClient openAiClient)
{
    public async Task<string> AnswerAsync(string userQuery,
        CancellationToken ct = default)
    {
        // Step 1: embed the query
        var queryEmbedding = await embedder.GetEmbeddingAsync(userQuery, ct);
        var queryVector    = new Vector(queryEmbedding);

        // Step 2: find top-5 semantically similar chunks
        var chunks = await db.Documents
            .OrderBy(d => d.Embedding.CosineDistance(queryVector))
            .Take(5)
            .Select(d => new { d.Title, d.Content })
            .ToListAsync(ct);

        // Step 3: build context-enriched prompt
        var context = string.Join("\n\n---\n\n",
            chunks.Select(c => $"Source: {c.Title}\n{c.Content}"));

        // Step 4: call LLM with context
        var messages = new List<ChatMessage>
        {
            ChatMessage.CreateSystemMessage(
                "You are a helpful assistant. Answer ONLY using the context below. " +
                "If the answer is not in the context, say 'I don't know'.\n\n" +
                $"CONTEXT:\n{context}"),
            ChatMessage.CreateUserMessage(userQuery)
        };

        var response = await openAiClient.GetChatCompletionsAsync(
            new ChatCompletionsOptions("gpt-4o-mini", messages), ct);

        return response.Value.Choices[0].Message.Content;
    }
}

// ── Document Ingestion ────────────────────────────────────────────────
public class DocumentIngestionService(AiDbContext db, EmbeddingService embedder)
{
    public async Task IngestAsync(string title, string content,
        string sourceUrl, CancellationToken ct = default)
    {
        // Chunk large documents (~ 512 tokens per chunk)
        var chunks = ChunkText(content, maxChunkSize: 2000);

        foreach (var chunk in chunks)
        {
            var embedding = await embedder.GetEmbeddingAsync(
                $"{title}\n{chunk}", ct);  // WHY: prepend title for context

            db.Documents.Add(new DocumentChunk
            {
                Title     = title,
                Content   = chunk,
                Embedding = new Vector(embedding),
                SourceUrl = sourceUrl,
                CreatedAt = DateTime.UtcNow
            });
        }

        await db.SaveChangesAsync(ct);
    }

    private static IEnumerable<string> ChunkText(string text, int maxChunkSize)
    {
        // Simple sliding window chunker
        // In production: use semantic chunking or tiktoken
        for (int i = 0; i < text.Length; i += maxChunkSize - 200) // 200 char overlap
        {
            var end = Math.Min(i + maxChunkSize, text.Length);
            yield return text[i..end];
            if (end == text.Length) break;
        }
    }
}
```

### Vector Search Use Cases

| Use Case | Query Type | Index |
|---------|-----------|-------|
| **Semantic document search** | Cosine similarity | HNSW cosine |
| **Product recommendation** | Cosine / inner product | HNSW cosine |
| **Duplicate detection** | L2 distance | HNSW L2 |
| **Image similarity** | L2 / Cosine | HNSW |
| **Chatbot memory (find relevant past messages)** | Cosine | HNSW cosine |
| **Code search** | Cosine (CodeBERT embeddings) | HNSW cosine |
| **Anomaly detection** | L2 (outliers have large distance) | IVFFlat L2 |
| **Customer segmentation** | K-means clustering on vectors | None (full scan) |

### Embedding Model Dimensions Reference

| Model | Dimensions | Provider | Best For |
|-------|-----------|---------|---------|
| text-embedding-3-small | 1536 | OpenAI | Cost-effective semantic search |
| text-embedding-3-large | 3072 | OpenAI | High accuracy semantic search |
| text-embedding-ada-002 | 1536 | OpenAI | Legacy (use 3-small instead) |
| nomic-embed-text | 768 | Nomic (open) | Open source, local |
| all-MiniLM-L6-v2 | 384 | HuggingFace | Fast, small, local |
| e5-large-v2 | 1024 | HuggingFace | High quality open source |
| mxbai-embed-large | 1024 | MixedBread | SOTA open source |

---

## 17. PostgreSQL with .NET / EF Core

```
┌─────────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Npgsql is to PostgreSQL what Microsoft.Data.SqlClient    │
│  is to SQL Server — the official .NET driver.                           │
└─────────────────────────────────────────────────────────────────────────┘
```

### NuGet Packages

```xml
<!-- Bare minimum -->
<PackageReference Include="Npgsql" Version="9.*" />

<!-- EF Core -->
<PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="9.*" />

<!-- pgvector support -->
<PackageReference Include="Pgvector" Version="0.2.*" />
<PackageReference Include="Pgvector.EntityFrameworkCore" Version="0.2.*" />

<!-- Dapper with Npgsql -->
<PackageReference Include="Dapper" Version="2.*" />
```

### Connection & DbContext Setup

```csharp
// Program.cs
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(
        builder.Configuration.GetConnectionString("Postgres"),
        npgsqlOptions =>
        {
            // WHY: register pgvector type mapping
            npgsqlOptions.UseVector();

            // WHY: resilience for transient failures
            npgsqlOptions.EnableRetryOnFailure(
                maxRetryCount: 3,
                maxRetryDelay: TimeSpan.FromSeconds(5),
                errorCodesToAdd: null);
        }
    )
    .UseSnakeCaseNamingConvention()  // WHY: PG convention is snake_case
);

// appsettings.json
{
  "ConnectionStrings": {
    "Postgres": "Host=localhost;Database=mydb;Username=postgres;Password=postgres;Pooling=true;MinPoolSize=5;MaxPoolSize=100;"
  }
}
```

### EF Core Migrations

```bash
# Add migration
dotnet ef migrations add InitialCreate

# Apply migration
dotnet ef database update

# Generate SQL script (review before prod deploy)
dotnet ef migrations script --idempotent -o migrations.sql

# Apply in CI/CD
dotnet ef database update --connection "Host=prod-server;..."
```

### EF Core PostgreSQL-Specific Features

```csharp
// JSONB column
public class User
{
    public long          Id       { get; set; }
    public string        Email    { get; set; } = "";
    // Map as JSONB (EF Core stores as JSON by default)
    public UserMetadata  Metadata { get; set; } = new();
}

// Query JSONB
var users = await db.Users
    .Where(u => u.Metadata.Tier == "premium")
    .ToListAsync();

// Array column
public class Report
{
    public long     Id   { get; set; }
    public string[] Tags { get; set; } = [];
}

// Query array
var reports = await db.Reports
    .Where(r => r.Tags.Contains("urgent"))
    .ToListAsync();

// PostgreSQL-specific operators in LINQ
using Npgsql.EntityFrameworkCore.PostgreSQL.Query.Expressions.Internal;

// Full-text search via EF Core
var results = await db.Posts
    .Where(p => EF.Functions.ToTsVector("english", p.Title + " " + p.Body)
                             .Matches("postgresql & performance"))
    .ToListAsync();

// Date truncation
var dailyCounts = await db.Events
    .GroupBy(e => EF.Functions.DateTruncDay(e.CreatedAt))
    .Select(g => new { Day = g.Key, Count = g.Count() })
    .ToListAsync();
```

### Dapper with PostgreSQL

```csharp
// Register Npgsql type mapping (for JSONB, UUID, etc.)
NpgsqlConnection.GlobalTypeMapper.UseJsonNet();  // or System.Text.Json

await using var connection = new NpgsqlConnection(connectionString);

// Parameterized query (use @param not ? like SQL Server)
var users = await connection.QueryAsync<User>(
    "SELECT id, email FROM app.users WHERE is_active = @IsActive LIMIT @Limit",
    new { IsActive = true, Limit = 20 });

// JSONB parameter
var payload = new { type = "click", userId = 42 };
await connection.ExecuteAsync(
    "INSERT INTO events (payload) VALUES (@Payload::jsonb)",
    new { Payload = JsonSerializer.Serialize(payload) });

// Array parameter
var ids = new long[] { 1, 2, 3 };
var result = await connection.QueryAsync<User>(
    "SELECT * FROM app.users WHERE id = ANY(@Ids)",
    new { Ids = ids });
```

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

*PostgreSQL Complete Guide — From SQL Server background to AI-ready vector search*
*Created: 2026-03-24 | Stack: PostgreSQL 16 + pgvector + .NET 10 + EF Core 9*
