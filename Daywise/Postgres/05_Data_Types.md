# 05 — Data Types — Full Reference
> Part of: [PostgreSQL Complete Guide](README.md)

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

*[← Previous: Architecture](04_Architecture.md) | [Back to Index](README.md) | [Next: DDL →](06_DDL.md)*
