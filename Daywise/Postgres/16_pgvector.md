# 16 — pgvector — AI Vector Database (Complete)
> Part of: [PostgreSQL Complete Guide](README.md)

---

## 16. pgvector — AI Vector Database (Complete)

```
┌─────────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Think of vectors as GPS coordinates for meaning.         │
│  "PostgreSQL + machine learning" = you can store the GPS coords         │
│  right next to your business data, and query both together with SQL.    │
│                                                                         │
│  Traditional search: "find rows WHERE title LIKE '%banking%'"           │
│  Vector search:      "find rows WHERE meaning SIMILAR TO 'banking'"     │
│                      → also finds 'finance', 'loans', 'credit'         │
└─────────────────────────────────────────────────────────────────────────┘
```

### What Are Vectors / Embeddings?

```
Text → Embedding Model → Vector (array of floats)

"The cat sat on the mat" → OpenAI text-embedding-3-small → [0.023, -0.145, 0.872, ...]
                                                             ↑ 1536 dimensions

Similar sentences → similar vectors → small distance between them
Different topics  → different vectors → large distance between them

Distance Metrics:
─────────────────────────────────────────────────────
L2 (Euclidean)    <->   : absolute spatial distance
Cosine similarity  <>   : angle between vectors (text/semantic)
Inner product      <#>  : dot product (normalized vectors)
```

### Setup pgvector

```sql
-- Enable extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Verify
SELECT * FROM pg_extension WHERE extname = 'vector';
```

### Schema Design for Vector Search

```sql
-- ── Document Store with Embeddings ──────────────────────────────────
CREATE TABLE ai.documents (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_url      TEXT,
    title           TEXT NOT NULL,
    content         TEXT NOT NULL,
    -- WHY vector(1536): OpenAI text-embedding-3-small dimension count
    -- For text-embedding-3-large: vector(3072)
    -- For Ada v2: vector(1536)
    -- For Nomic embed: vector(768)
    embedding       vector(1536),
    metadata        JSONB NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Chat Message Store ───────────────────────────────────────────────
CREATE TABLE ai.messages (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    session_id  UUID NOT NULL,
    role        TEXT NOT NULL CHECK (role IN ('user','assistant','system')),
    content     TEXT NOT NULL,
    embedding   vector(1536),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Product Catalog with Semantic Search ─────────────────────────────
CREATE TABLE ai.products (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku         TEXT NOT NULL UNIQUE,
    name        TEXT NOT NULL,
    description TEXT,
    category    TEXT,
    price       NUMERIC(10,2),
    embedding   vector(1536),    -- semantic embedding of name+description
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Vector Indexes

```sql
-- ── IVFFlat Index (approximate, faster to build) ─────────────────────
-- WHY: Use when table has > 100K rows
-- Rule: lists = rows / 1000 (min 100)
CREATE INDEX idx_documents_embedding_ivfflat
    ON ai.documents
    USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);
-- vector_cosine_ops  = cosine distance (best for text embeddings)
-- vector_l2_ops      = L2 distance (Euclidean)
-- vector_ip_ops      = inner product (for normalized vectors)

-- ── HNSW Index (approximate, faster queries, more memory) ────────────
-- WHY: Use for production — better recall than IVFFlat, faster queries
-- Available in pgvector 0.5.0+
CREATE INDEX idx_documents_embedding_hnsw
    ON ai.documents
    USING hnsw (embedding vector_cosine_ops)
    WITH (m = 16, ef_construction = 64);
-- m = number of bi-directional links per node (16-64)
-- ef_construction = size of dynamic candidate list during build (64-200)

-- Set probes for IVFFlat queries (more = better recall, slower)
SET ivfflat.probes = 10;

-- Set ef_search for HNSW queries (more = better recall, slower)
SET hnsw.ef_search = 100;
```

### Similarity Search Queries

```sql
-- ── Cosine Similarity Search ─────────────────────────────────────────
-- Find 5 most semantically similar documents to a query vector
SELECT
    id,
    title,
    content,
    1 - (embedding <=> '[0.1, 0.2, ...]'::vector) AS cosine_similarity
FROM ai.documents
ORDER BY embedding <=> '[0.1, 0.2, ...]'::vector  -- <=> = cosine distance
LIMIT 5;

-- ── L2 Distance Search ───────────────────────────────────────────────
SELECT id, title,
       embedding <-> '[0.1, 0.2, ...]'::vector AS l2_distance
FROM   ai.documents
ORDER  BY embedding <-> '[0.1, 0.2, ...]'::vector  -- <-> = L2 distance
LIMIT  5;

-- ── Hybrid Search (Vector + Keyword + Filters) ───────────────────────
-- WHY: Pure vector search can miss exact keyword matches; hybrid wins
WITH semantic_search AS (
    SELECT id, RANK() OVER (ORDER BY embedding <=> $1) AS vector_rank
    FROM   ai.documents
    WHERE  metadata->>'category' = 'technical'   -- metadata filter
    ORDER  BY embedding <=> $1
    LIMIT  20
),
keyword_search AS (
    SELECT id, RANK() OVER (ORDER BY ts_rank(search_vector, to_tsquery('english', $2))) AS text_rank
    FROM   ai.documents
    WHERE  search_vector @@ to_tsquery('english', $2)
    LIMIT  20
)
-- Reciprocal Rank Fusion (RRF) scoring
SELECT
    d.id, d.title, d.content,
    COALESCE(1.0 / (60 + s.vector_rank), 0) +
    COALESCE(1.0 / (60 + k.text_rank), 0) AS rrf_score
FROM ai.documents d
LEFT JOIN semantic_search s ON s.id = d.id
LEFT JOIN keyword_search   k ON k.id = d.id
WHERE s.id IS NOT NULL OR k.id IS NOT NULL
ORDER BY rrf_score DESC
LIMIT 10;

-- ── Similarity Threshold (only return close matches) ─────────────────
SELECT id, title,
       1 - (embedding <=> $1::vector) AS similarity
FROM   ai.documents
WHERE  1 - (embedding <=> $1::vector) > 0.75   -- only > 75% similar
ORDER  BY similarity DESC
LIMIT  10;
```

### RAG (Retrieval-Augmented Generation) Pattern

```
┌─────────────────────────────────────────────────────────────────────────┐
│  RAG Architecture with pgvector:                                        │
│                                                                         │
│  User Query                                                             │
│      │                                                                  │
│      ▼                                                                  │
│  Embedding Model (OpenAI / HuggingFace)                                 │
│      │ query_vector                                                     │
│      ▼                                                                  │
│  pgvector: SELECT ... ORDER BY embedding <=> query_vector LIMIT 5       │
│      │ top_k_chunks                                                     │
│      ▼                                                                  │
│  Build Prompt: system + context_chunks + user_query                     │
│      │                                                                  │
│      ▼                                                                  │
│  LLM (GPT-4 / Claude / Llama) → Answer                                 │
└─────────────────────────────────────────────────────────────────────────┘
```

### Full RAG Implementation in C# with pgvector

```csharp
// ── NuGet packages needed ────────────────────────────────────────────
// Npgsql.EntityFrameworkCore.PostgreSQL
// Pgvector.EntityFrameworkCore
// Azure.AI.OpenAI  (or OpenAI)

// ── EF Core Entity ───────────────────────────────────────────────────
using Pgvector;

public record DocumentChunk
{
    public long     Id          { get; init; }
    public string   Title       { get; init; } = "";
    public string   Content     { get; init; } = "";
    public Vector   Embedding   { get; init; } = null!;   // pgvector type
    public string   SourceUrl   { get; init; } = "";
    public DateTime CreatedAt   { get; init; }
}

// ── DbContext ────────────────────────────────────────────────────────
public class AiDbContext : DbContext
{
    public DbSet<DocumentChunk> Documents { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // WHY: register pgvector extension with EF Core
        modelBuilder.HasPostgresExtension("vector");

        modelBuilder.Entity<DocumentChunk>(e =>
        {
            e.ToTable("documents", "ai");
            e.HasKey(x => x.Id);

            // WHY: map the Vector type to pgvector column
            e.Property(x => x.Embedding)
             .HasColumnType("vector(1536)");

            // HNSW index via EF Core migrations
            e.HasIndex(x => x.Embedding)
             .HasMethod("hnsw")
             .HasOperators("vector_cosine_ops")
             .HasStorageParameter("m", 16)
             .HasStorageParameter("ef_construction", 64);
        });
    }
}

// ── Embedding Service ─────────────────────────────────────────────────
public class EmbeddingService(OpenAIClient openAiClient)
{
    private const string Model = "text-embedding-3-small";

    public async Task<float[]> GetEmbeddingAsync(string text,
        CancellationToken ct = default)
    {
        var response = await openAiClient.GetEmbeddingsAsync(
            new EmbeddingsOptions(Model, [text]), ct);

        // WHY: normalize to unit vector for cosine similarity
        return response.Value.Data[0].Embedding.ToArray();
    }
}

// ── RAG Service ───────────────────────────────────────────────────────
public class RagService(AiDbContext db, EmbeddingService embedder,
    OpenAIClient openAiClient)
{
    public async Task<string> AnswerAsync(string userQuery,
        CancellationToken ct = default)
    {
        // Step 1: embed the query
        var queryEmbedding = await embedder.GetEmbeddingAsync(userQuery, ct);
        var queryVector    = new Vector(queryEmbedding);

        // Step 2: find top-5 semantically similar chunks
        var chunks = await db.Documents
            .OrderBy(d => d.Embedding.CosineDistance(queryVector))
            .Take(5)
            .Select(d => new { d.Title, d.Content })
            .ToListAsync(ct);

        // Step 3: build context-enriched prompt
        var context = string.Join("\n\n---\n\n",
            chunks.Select(c => $"Source: {c.Title}\n{c.Content}"));

        // Step 4: call LLM with context
        var messages = new List<ChatMessage>
        {
            ChatMessage.CreateSystemMessage(
                "You are a helpful assistant. Answer ONLY using the context below. " +
                "If the answer is not in the context, say 'I don't know'.\n\n" +
                $"CONTEXT:\n{context}"),
            ChatMessage.CreateUserMessage(userQuery)
        };

        var response = await openAiClient.GetChatCompletionsAsync(
            new ChatCompletionsOptions("gpt-4o-mini", messages), ct);

        return response.Value.Choices[0].Message.Content;
    }
}

// ── Document Ingestion ────────────────────────────────────────────────
public class DocumentIngestionService(AiDbContext db, EmbeddingService embedder)
{
    public async Task IngestAsync(string title, string content,
        string sourceUrl, CancellationToken ct = default)
    {
        // Chunk large documents (~ 512 tokens per chunk)
        var chunks = ChunkText(content, maxChunkSize: 2000);

        foreach (var chunk in chunks)
        {
            var embedding = await embedder.GetEmbeddingAsync(
                $"{title}\n{chunk}", ct);  // WHY: prepend title for context

            db.Documents.Add(new DocumentChunk
            {
                Title     = title,
                Content   = chunk,
                Embedding = new Vector(embedding),
                SourceUrl = sourceUrl,
                CreatedAt = DateTime.UtcNow
            });
        }

        await db.SaveChangesAsync(ct);
    }

    private static IEnumerable<string> ChunkText(string text, int maxChunkSize)
    {
        // Simple sliding window chunker
        // In production: use semantic chunking or tiktoken
        for (int i = 0; i < text.Length; i += maxChunkSize - 200) // 200 char overlap
        {
            var end = Math.Min(i + maxChunkSize, text.Length);
            yield return text[i..end];
            if (end == text.Length) break;
        }
    }
}
```

### Vector Search Use Cases

| Use Case | Query Type | Index |
|---------|-----------|-------|
| **Semantic document search** | Cosine similarity | HNSW cosine |
| **Product recommendation** | Cosine / inner product | HNSW cosine |
| **Duplicate detection** | L2 distance | HNSW L2 |
| **Image similarity** | L2 / Cosine | HNSW |
| **Chatbot memory (find relevant past messages)** | Cosine | HNSW cosine |
| **Code search** | Cosine (CodeBERT embeddings) | HNSW cosine |
| **Anomaly detection** | L2 (outliers have large distance) | IVFFlat L2 |
| **Customer segmentation** | K-means clustering on vectors | None (full scan) |

### Embedding Model Dimensions Reference

| Model | Dimensions | Provider | Best For |
|-------|-----------|---------|---------|
| text-embedding-3-small | 1536 | OpenAI | Cost-effective semantic search |
| text-embedding-3-large | 3072 | OpenAI | High accuracy semantic search |
| text-embedding-ada-002 | 1536 | OpenAI | Legacy (use 3-small instead) |
| nomic-embed-text | 768 | Nomic (open) | Open source, local |
| all-MiniLM-L6-v2 | 384 | HuggingFace | Fast, small, local |
| e5-large-v2 | 1024 | HuggingFace | High quality open source |
| mxbai-embed-large | 1024 | MixedBread | SOTA open source |

---

*[← Previous: Extensions](15_Extensions.md) | [Back to Index](README.md) | [Next: PostgreSQL with .NET / EF Core →](17_DotNet_EFCore.md)*
