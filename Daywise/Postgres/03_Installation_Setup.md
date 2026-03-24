# 03 — Installation & Setup (Local + Docker)
> Part of: [PostgreSQL Complete Guide](README.md)

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

*[← Previous: Core Concepts](02_Core_Concepts.md) | [Back to Index](README.md) | [Next: Architecture →](04_Architecture.md)*
