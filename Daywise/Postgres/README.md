# PostgreSQL — Complete Guide: Beginner to Expert + AI Vector DB
> From SQL Server background → PostgreSQL mastery → pgvector for AI workloads
> Mental Model: PostgreSQL is SQL Server's open-source cousin — same relational DNA, different dialect, supercharged extensions

---

## Table of Contents

| # | File | Topic | Size |
|---|------|-------|------|
| 1 | [01_Why_PostgreSQL.md](01_Why_PostgreSQL.md) | Why PostgreSQL? — Advantages Over SQL Server | ~50 lines |
| 2 | [02_Core_Concepts.md](02_Core_Concepts.md) | Core Concepts — SQL Server vs PostgreSQL Mapping | ~55 lines |
| 3 | [03_Installation_Setup.md](03_Installation_Setup.md) | Installation & Setup (Local + Docker) | ~97 lines |
| 4 | [04_Architecture.md](04_Architecture.md) | PostgreSQL Architecture Deep Dive | ~60 lines |
| 5 | [05_Data_Types.md](05_Data_Types.md) | Data Types — Full Reference | ~130 lines |
| 6 | [06_DDL.md](06_DDL.md) | DDL — Tables, Schemas, Constraints | ~97 lines |
| 7 | [07_DML.md](07_DML.md) | DML — CRUD with PostgreSQL Flavor | ~119 lines |
| 8 | [08_Indexes.md](08_Indexes.md) | Indexes — Types & When to Use | ~81 lines |
| 9 | [09_Advanced_Queries.md](09_Advanced_Queries.md) | Advanced Queries — CTEs, Window Functions, JSONB | ~140 lines |
| 10 | [10_Transactions_Concurrency.md](10_Transactions_Concurrency.md) | Transactions & Concurrency (MVCC) | ~64 lines |
| 11 | [11_Stored_Procedures_Triggers.md](11_Stored_Procedures_Triggers.md) | Stored Procedures, Functions & Triggers | ~135 lines |
| 12 | [12_Performance_Tuning.md](12_Performance_Tuning.md) | Performance Tuning & EXPLAIN ANALYZE | ~122 lines |
| 13 | [13_Replication_HA.md](13_Replication_HA.md) | Replication & High Availability | ~33 lines |
| 14 | [14_Security.md](14_Security.md) | Security — Roles, RLS, Encryption | ~76 lines |
| 15 | [15_Extensions.md](15_Extensions.md) | PostgreSQL Extensions Ecosystem | ~39 lines |
| 16 | [16_pgvector.md](16_pgvector.md) | pgvector — AI Vector Database (Complete) | ~365 lines |
| 17 | [17_DotNet_EFCore.md](17_DotNet_EFCore.md) | PostgreSQL with .NET / EF Core | ~144 lines |
| 18 | [18_Azure_Flexible_Server.md](18_Azure_Flexible_Server.md) | PostgreSQL on Azure (Flexible Server) | ~120 lines |
| 19 | [19_Production_Checklist.md](19_Production_Checklist.md) | Production Checklist & Monitoring | ~83 lines |
| 20 | [20_Interview_QA.md](20_Interview_QA.md) | Interview Q&A — 30 Expert Questions | ~137 lines |

---

## Quick Navigation by Topic

### Foundations
- [Why PostgreSQL vs SQL Server](01_Why_PostgreSQL.md)
- [Terminology Mapping (SQL Server → PG)](02_Core_Concepts.md)
- [Docker Setup + psql commands](03_Installation_Setup.md)
- [Architecture: MVCC, WAL, Autovacuum](04_Architecture.md)

### Core SQL
- [Data Types: JSONB, TIMESTAMPTZ, UUID, Arrays](05_Data_Types.md)
- [DDL: Tables, Schemas, Enums, Triggers](06_DDL.md)
- [DML: UPSERT, RETURNING, COPY, DISTINCT ON](07_DML.md)
- [Indexes: B-Tree, GIN, HNSW, IVFFlat, Partial](08_Indexes.md)
- [Advanced: CTEs (Writeable/Recursive), Window Functions, JSONB ops](09_Advanced_Queries.md)

### Internals & Operations
- [Transactions, Isolation Levels, SKIP LOCKED](10_Transactions_Concurrency.md)
- [PL/pgSQL Functions, Procedures, Audit Triggers](11_Stored_Procedures_Triggers.md)
- [EXPLAIN ANALYZE, VACUUM, Partitioning, postgresql.conf](12_Performance_Tuning.md)
- [Streaming Replication, Logical Replication, Patroni](13_Replication_HA.md)
- [Roles, RLS (Row-Level Security), pgcrypto](14_Security.md)
- [Extensions: PostGIS, TimescaleDB, pg_cron, Citus](15_Extensions.md)

### AI & Modern Stack
- [pgvector: Embeddings, HNSW, RAG in C#](16_pgvector.md)
- [Npgsql, EF Core, Dapper with PostgreSQL](17_DotNet_EFCore.md)
- [Azure Flexible Server, Bicep, Supabase](18_Azure_Flexible_Server.md)

### Production & Interview
- [Production Checklist, pgBouncer, Monitoring Queries](19_Production_Checklist.md)
- [25 Expert Interview Q&A + Quick Reference](20_Interview_QA.md)

---

## 🎬 Core Video Resources

| Video | Channel | What it covers |
|-------|---------|----------------|
| [PostgreSQL in 100 Seconds](https://www.youtube.com/watch?v=n2Fluyr3lbc) | Fireship | Quick overview, extensions, AI use case |
| [Learn PostgreSQL — 4 hr Full Course](https://www.youtube.com/watch?v=qw--VYLpxG4) | Amigoscode · freeCodeCamp | Beginner → DDL, DML, constraints, joins |
| [PostgreSQL Tutorial — 3 hr Beginner](https://www.youtube.com/watch?v=SpfIwlAYaKk) | freeCodeCamp | SELECT, aggregate, GROUP BY, advanced queries |
| [Hussein Nasser — PostgreSQL Internals](https://www.youtube.com/@hnasr) | @hnasr | Architecture, MVCC, indexing, locking, WAL |
| [Crunchy Data — Production PostgreSQL](https://www.youtube.com/c/CrunchyDataPostgres) | CrunchyData | CTEs, window functions, EXPLAIN, production |

> Each section file (01–20) has its own `🎬 Quick Learn` table with topic-specific video links.

---

*Stack: PostgreSQL 16 + pgvector + .NET 10 + EF Core 9 + Azure Flexible Server*
*Created: 2026-03-24 | Split from: [PostgreSQL_Complete_Guide.md](PostgreSQL_Complete_Guide.md)*
