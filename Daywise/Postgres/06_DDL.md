# 06 — DDL — Tables, Schemas, Constraints
> Part of: [PostgreSQL Complete Guide](README.md)

---

## 🎬 Quick Learn

| Format | Video |
|--------|-------|
| **📘 Full Course** | [Learn PostgreSQL — Amigoscode · 4 hr](https://www.youtube.com/watch?v=qw--VYLpxG4) `freeCodeCamp` — CREATE TABLE, constraints, foreign keys |
| **🔍 DDL Deep Dive** | [PostgreSQL DDL Tables Schemas Constraints — YouTube Search](https://www.youtube.com/results?search_query=postgresql+DDL+create+table+schema+constraints+tutorial) |

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

*[← Previous: Data Types](05_Data_Types.md) | [Back to Index](README.md) | [Next: DML →](07_DML.md)*
