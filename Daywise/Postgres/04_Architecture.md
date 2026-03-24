# 04 — PostgreSQL Architecture Deep Dive
> Part of: [PostgreSQL Complete Guide](README.md)

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

*[← Previous: Installation & Setup](03_Installation_Setup.md) | [Back to Index](README.md) | [Next: Data Types →](05_Data_Types.md)*
