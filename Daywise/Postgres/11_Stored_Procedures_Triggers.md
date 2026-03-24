# 11 — Stored Procedures, Functions & Triggers
> Part of: [PostgreSQL Complete Guide](README.md)

---

## 🎬 Quick Learn

| Format | Video |
|--------|-------|
| **🔧 PL/pgSQL** | [PostgreSQL PL/pgSQL Functions & Procedures — YouTube Search](https://www.youtube.com/results?search_query=postgresql+plpgsql+stored+procedures+functions+tutorial) |
| **⚡ Triggers** | [PostgreSQL Triggers Audit Log — YouTube Search](https://www.youtube.com/results?search_query=postgresql+triggers+audit+log+plpgsql+tutorial+2023) |
| **📘 Full Reference** | [PostgreSQL Full Course — Derek Banas · YouTube Search](https://www.youtube.com/results?search_query=postgresql+tutorial+full+course+derek+banas+functions+triggers) |

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

*[← Previous: Transactions & Concurrency](10_Transactions_Concurrency.md) | [Back to Index](README.md) | [Next: Performance Tuning →](12_Performance_Tuning.md)*
