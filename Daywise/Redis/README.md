# Redis — Complete .NET Study Guide

> Everything you need to know about Redis for .NET interviews and production use.

---

## Guides Index

| # | File | Topic | Key Concepts |
|---|------|-------|-------------|
| 00 | [00-Redis-Overview-DataTypes.md](00-Redis-Overview-DataTypes.md) | Overview & All Data Types | String, Hash, List, Set, ZSet, HLL, Geo, Bitmap, Streams |
| 01 | [01-Redis-Caching-Patterns.md](01-Redis-Caching-Patterns.md) | Caching Patterns | Cache-Aside, Write-Through, Write-Behind, Read-Through, Refresh-Ahead, Stampede Prevention |
| 02 | [02-Redis-Session-Distributed-State.md](02-Redis-Session-Distributed-State.md) | Session & State | ASP.NET Core Session, JWT Blacklist, Shopping Cart, OTP Tokens |
| 03 | [03-Redis-PubSub-Messaging.md](03-Redis-PubSub-Messaging.md) | Pub/Sub | Channels, Pattern Subscriptions, SignalR Backplane, Keyspace Notifications |
| 04 | [04-Redis-Distributed-Locking.md](04-Redis-Distributed-Locking.md) | Distributed Locks | SET NX EX, Lua Release, RedLock, Watchdog, Idempotency Keys |
| 05 | [05-Redis-Rate-Limiting.md](05-Redis-Rate-Limiting.md) | Rate Limiting | Fixed Window, Sliding Window, Token Bucket, Leaky Bucket, .NET Middleware |
| 06 | [06-Redis-Streams.md](06-Redis-Streams.md) | Redis Streams | XADD/XREAD, Consumer Groups, ACK, DLQ, Event Sourcing, Outbox Pattern |
| 07 | [07-Redis-Leaderboards-SortedSets.md](07-Redis-Leaderboards-SortedSets.md) | Sorted Sets | Leaderboards, Multi-Period, Priority Queue, Delayed Jobs, Activity Feed, Trending |
| 08 | [08-Redis-Advanced-Patterns.md](08-Redis-Advanced-Patterns.md) | Advanced | Pipelines, Transactions, Lua Scripts, Bloom Filter, Two-Level Cache, Cluster, Azure |


https://www.youtube.com/watch?v=XCsS_NVAa1g&t=2938s
--
https://www.youtube.com/watch?v=Tt5zIKVMMbs
--
https://www.youtube.com/watch?v=i_3I6XLAOt0
--
https://www.youtube.com/watch?v=SzLhUq1Hezk&t=394s
--
https://www.youtube.com/watch?v=4UP6L8cDBN8
---

## Quick Decision Map

```
What do I need?
│
├── Store data temporarily          → String / Hash with TTL
├── Cache DB results                → Guide 01 (Cache-Aside pattern)
├── User session across servers     → Guide 02 (Distributed Session)
├── Real-time notifications         → Guide 03 (Pub/Sub)
├── Prevent duplicate processing    → Guide 04 (Distributed Lock)
├── Limit API requests              → Guide 05 (Rate Limiting)
├── Durable message queue           → Guide 06 (Streams)
├── Leaderboard / Top-N             → Guide 07 (Sorted Sets)
├── Fast batch operations           → Guide 08 (Pipelines)
└── All data types reference        → Guide 00 (Overview)
```

---

## Tech Stack Used in Examples

- **Client:** StackExchange.Redis 2.7+
- **Framework:** ASP.NET Core 8/10 Minimal APIs
- **Hosting:** Azure Cache for Redis (Premium)
- **Libraries:** RedLock.net, MessagePack, System.Text.Json
- **Observability:** ILogger<T>, Application Insights
