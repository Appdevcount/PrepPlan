# 14 — Security — Roles, RLS, Encryption
> Part of: [PostgreSQL Complete Guide](README.md)

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

*[← Previous: Replication & HA](13_Replication_HA.md) | [Back to Index](README.md) | [Next: Extensions →](15_Extensions.md)*
