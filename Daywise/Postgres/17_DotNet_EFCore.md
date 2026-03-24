# 17 — PostgreSQL with .NET / EF Core
> Part of: [PostgreSQL Complete Guide](README.md)

---

## 🎬 Quick Learn

| Format | Video |
|--------|-------|
| **⚙️ EF Core Setup** | [PostgreSQL EF Core .NET Tutorial — YouTube Search](https://www.youtube.com/results?search_query=postgresql+entity+framework+core+dotnet+npgsql+tutorial+2024) |
| **🐘 Npgsql + Dapper** | [PostgreSQL Dapper .NET Npgsql — YouTube Search](https://www.youtube.com/results?search_query=postgresql+dapper+npgsql+dotnet+csharp+tutorial) |
| **🗃️ Migrations** | [EF Core Migrations PostgreSQL — YouTube Search](https://www.youtube.com/results?search_query=entity+framework+core+migrations+postgresql+dotnet+tutorial) |

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

*[← Previous: pgvector](16_pgvector.md) | [Back to Index](README.md) | [Next: Azure (Flexible Server) →](18_Azure_Flexible_Server.md)*
