# 10 — Transactions & Concurrency (MVCC)
> Part of: [PostgreSQL Complete Guide](README.md)

---

## 🎬 Quick Learn

| Format | Video |
|--------|-------|
| **🔒 MVCC Explained** | [PostgreSQL MVCC Concurrency Control — YouTube Search](https://www.youtube.com/results?search_query=postgresql+MVCC+multi+version+concurrency+control+explained) |
| **📊 Isolation Levels** | [Database Isolation Levels Explained — YouTube Search](https://www.youtube.com/results?search_query=database+transaction+isolation+levels+explained+postgresql) |
| **🔑 Locking** | [PostgreSQL Locking SELECT FOR UPDATE SKIP LOCKED — YouTube Search](https://www.youtube.com/results?search_query=postgresql+locking+select+for+update+skip+locked+advisory+locks) |

> **Channel**: [Hussein Nasser (@hnasr)](https://www.youtube.com/@hnasr) — covers ACID, MVCC, isolation in depth

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

*[← Previous: Advanced Queries](09_Advanced_Queries.md) | [Back to Index](README.md) | [Next: Stored Procedures & Triggers →](11_Stored_Procedures_Triggers.md)*
