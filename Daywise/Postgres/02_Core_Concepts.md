# 02 — Core Concepts — SQL Server vs PostgreSQL Mapping
> Part of: [PostgreSQL Complete Guide](README.md)

---

## 🎬 Quick Learn

| Format | Video |
|--------|-------|
| **📘 Full Course** | [Learn PostgreSQL — Amigoscode · 4 hr](https://www.youtube.com/watch?v=qw--VYLpxG4) `freeCodeCamp` — covers terminology, connection strings |
| **🔍 Deep Dive** | [PostgreSQL Core Concepts Explained — YouTube Search](https://www.youtube.com/results?search_query=postgresql+core+concepts+sql+server+comparison+tutorial) |

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

*[← Previous: Why PostgreSQL](01_Why_PostgreSQL.md) | [Back to Index](README.md) | [Next: Installation & Setup →](03_Installation_Setup.md)*
