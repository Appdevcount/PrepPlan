# Redis — Pub/Sub & Messaging in .NET

> **Mental Model:** Redis Pub/Sub is a radio station. Publishers broadcast on a channel. Subscribers tune in.
> Messages are fire-and-forget — if no subscriber is listening, the message is lost.
> For durable messaging, use Redis Streams (see guide 06).

---

## Table of Contents
1. [Pub/Sub vs Streams vs Service Bus](#pubsub-vs-streams-vs-service-bus)
2. [Basic Pub/Sub in .NET](#basic-pubsub-in-net)
3. [Pattern Subscriptions (Glob)](#pattern-subscriptions-glob)
4. [Hosted Service Subscriber (Background Worker)](#hosted-service-subscriber)
5. [Real-World Use Cases](#real-world-use-cases)
   - [Cache Invalidation Broadcast](#cache-invalidation-broadcast)
   - [Live Notifications](#live-notifications)
   - [Chat System](#chat-system)
   - [Real-Time Dashboard Updates](#real-time-dashboard-updates)
6. [Pub/Sub + SignalR Integration](#pubsub--signalr-integration)
7. [Redis Keyspace Notifications](#redis-keyspace-notifications)
8. [Limitations & When NOT to Use Pub/Sub](#limitations--when-not-to-use-pubsub)

---

## Pub/Sub vs Streams vs Service Bus

```
┌───────────────────┬─────────────────────┬─────────────────────────────┐
│ Feature           │ Redis Pub/Sub        │ Redis Streams               │
├───────────────────┼─────────────────────┼─────────────────────────────┤
│ Durability        │ ❌ Fire-and-forget   │ ✅ Persisted until ACKed    │
│ Replay            │ ❌ No               │ ✅ Yes (by offset)          │
│ Consumer groups   │ ❌ No               │ ✅ Yes (competing consumers)│
│ Delivery guarantee│ At-most-once        │ At-least-once               │
│ Latency           │ Sub-millisecond     │ Sub-millisecond             │
│ Message history   │ ❌ No               │ ✅ Yes                      │
│ Best for          │ Notifications, cache│ Task queues, event sourcing │
│                   │ invalidation, chat  │ audit logs, microservices   │
└───────────────────┴─────────────────────┴─────────────────────────────┘

Redis Pub/Sub vs Azure Service Bus:
  Use Redis Pub/Sub: in-process signaling, cache invalidation, <10ms latency needed
  Use Service Bus: guaranteed delivery, dead-letter queue, cross-service messaging
```

---

## Basic Pub/Sub in .NET

### Setup
```csharp
// WHY: ISubscriber is the Pub/Sub interface from StackExchange.Redis
// Get from the same ConnectionMultiplexer singleton
builder.Services.AddSingleton<ISubscriber>(sp =>
    sp.GetRequiredService<IConnectionMultiplexer>().GetSubscriber());
```

### Publisher
```csharp
public class EventPublisher
{
    private readonly ISubscriber _subscriber;

    public EventPublisher(ISubscriber subscriber)
        => _subscriber = subscriber;

    // WHY: PublishAsync is fire-and-forget — don't await if you don't care about subscriber count
    public async Task<long> PublishAsync<T>(string channel, T message)
    {
        var json = JsonSerializer.Serialize(message);

        // Returns: number of subscribers that received the message
        // WHY: If 0 returned, no one is listening — log this in critical systems
        long subscriberCount = await _subscriber.PublishAsync(
            RedisChannel.Literal(channel), json);

        return subscriberCount;
    }
}

// Usage
public class OrderService
{
    private readonly EventPublisher _publisher;

    public async Task CreateOrderAsync(CreateOrderDto dto)
    {
        // ... create order in DB ...

        // Broadcast event — no coupling to consumers
        await _publisher.PublishAsync("orders:created", new
        {
            OrderId = order.Id,
            UserId = order.UserId,
            Amount = order.Total,
            Timestamp = DateTime.UtcNow
        });
    }
}
```

### Subscriber
```csharp
public class EventSubscriber
{
    private readonly ISubscriber _subscriber;
    private readonly ILogger<EventSubscriber> _logger;

    // Subscribe to a channel (channel = exact string)
    public async Task SubscribeAsync(string channel, Func<string, Task> handler)
    {
        await _subscriber.SubscribeAsync(
            RedisChannel.Literal(channel),
            async (ch, message) =>
            {
                try
                {
                    await handler(message.ToString()!);
                }
                catch (Exception ex)
                {
                    // WHY: Exceptions in subscriber callbacks are swallowed by StackExchange.Redis
                    // Always wrap in try-catch and log — otherwise failures disappear silently
                    _logger.LogError(ex, "Error processing message on channel {Channel}", channel);
                }
            });
    }

    public async Task UnsubscribeAsync(string channel)
        => await _subscriber.UnsubscribeAsync(RedisChannel.Literal(channel));

    public async Task UnsubscribeAllAsync()
        => await _subscriber.UnsubscribeAllAsync();
}
```

---

## Pattern Subscriptions (Glob)

```csharp
// WHY: Pattern subscriptions use glob syntax to match multiple channels at once
// Useful when you have dynamic channel names (e.g., per-user, per-tenant)

await _subscriber.SubscribeAsync(
    RedisChannel.Pattern("orders:*"),  // matches orders:created, orders:shipped, etc.
    async (channel, message) =>
    {
        // channel = the actual channel (e.g., "orders:created")
        // message = the message content
        var eventType = channel.ToString().Split(':')[1]; // "created", "shipped", etc.
        await HandleOrderEventAsync(eventType, message.ToString()!);
    });

// WHY: Pattern subscribe uses PSUBSCRIBE command — slightly more expensive than SUBSCRIBE
// Use SUBSCRIBE for known, fixed channels; PSUBSCRIBE for dynamic channel namespaces
```

---

## Hosted Service Subscriber

```csharp
// WHY: Background service ensures subscriber is always running
// and resubscribes automatically on reconnect
public class OrderEventSubscriber : IHostedService
{
    private readonly ISubscriber _subscriber;
    private readonly IServiceScopeFactory _scopeFactory; // WHY: Scoped services need factory in singleton
    private readonly ILogger<OrderEventSubscriber> _logger;

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        // WHY: Subscribe on startup — runs for the lifetime of the app
        await _subscriber.SubscribeAsync(
            RedisChannel.Literal("orders:created"),
            async (channel, message) => await HandleOrderCreatedAsync(message));

        await _subscriber.SubscribeAsync(
            RedisChannel.Pattern("notifications:user:*"),
            async (channel, message) => await HandleUserNotificationAsync(channel, message));

        _logger.LogInformation("Order event subscriber started");
    }

    private async Task HandleOrderCreatedAsync(RedisValue message)
    {
        // WHY: Create a scope so we can resolve scoped services (DbContext, etc.)
        using var scope = _scopeFactory.CreateScope();
        var emailService = scope.ServiceProvider.GetRequiredService<IEmailService>();

        try
        {
            var orderEvent = JsonSerializer.Deserialize<OrderCreatedEvent>(message.ToString()!);
            await emailService.SendOrderConfirmationAsync(orderEvent!.UserId, orderEvent.OrderId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to handle order:created event");
        }
    }

    private async Task HandleUserNotificationAsync(RedisChannel channel, RedisValue message)
    {
        // Extract userId from channel name: "notifications:user:42" → 42
        var parts = channel.ToString().Split(':');
        var userId = int.Parse(parts[2]);

        _logger.LogDebug("Notification for user {UserId}: {Message}", userId, message);
        // Push to SignalR, WebSocket, etc.
    }

    public async Task StopAsync(CancellationToken cancellationToken)
        => await _subscriber.UnsubscribeAllAsync();
}

// Registration
builder.Services.AddHostedService<OrderEventSubscriber>();
```

---

## Real-World Use Cases

### Cache Invalidation Broadcast

```csharp
// ── Problem: Multiple app instances have local in-memory caches
// When one instance updates data, others still serve stale cached data
// Solution: Broadcast invalidation via Redis Pub/Sub

// ── Publisher (on data change) ─────────────────────────────────────────
public class CacheInvalidationPublisher
{
    private readonly ISubscriber _subscriber;
    private const string Channel = "cache:invalidate";

    public async Task InvalidateAsync(string cacheKey)
        => await _subscriber.PublishAsync(RedisChannel.Literal(Channel), cacheKey);

    public async Task InvalidateByTagAsync(string tag)
        => await _subscriber.PublishAsync(RedisChannel.Literal("cache:invalidate:tag"), tag);
}

// ── Subscriber (in every app instance) ────────────────────────────────
public class CacheInvalidationHostedService : IHostedService
{
    private readonly ISubscriber _subscriber;
    private readonly IMemoryCache _localCache;

    public async Task StartAsync(CancellationToken ct)
    {
        await _subscriber.SubscribeAsync(
            RedisChannel.Literal("cache:invalidate"),
            (_, key) =>
            {
                // WHY: Synchronous removal — MemoryCache.Remove is thread-safe
                _localCache.Remove(key.ToString());
            });
    }

    public async Task StopAsync(CancellationToken ct)
        => await _subscriber.UnsubscribeAllAsync();
}
```

---

### Live Notifications

```csharp
// ── Notification Event ─────────────────────────────────────────────────
public record NotificationEvent(
    string UserId,
    string Type,       // "order_shipped", "message_received", etc.
    string Title,
    string Body,
    DateTime Timestamp);

// ── Publisher ─────────────────────────────────────────────────────────
public class NotificationPublisher
{
    private readonly ISubscriber _subscriber;

    public async Task SendToUserAsync(string userId, NotificationEvent notification)
    {
        // WHY: Per-user channels enable targeted delivery without broadcasting to all users
        string channel = $"notifications:user:{userId}";
        await _subscriber.PublishAsync(
            RedisChannel.Literal(channel),
            JsonSerializer.Serialize(notification));
    }

    public async Task BroadcastAsync(NotificationEvent notification)
    {
        // Send to all users (e.g., system maintenance announcement)
        await _subscriber.PublishAsync(
            RedisChannel.Literal("notifications:broadcast"),
            JsonSerializer.Serialize(notification));
    }
}
```

---

### Chat System

```csharp
// ── Chat with Redis Pub/Sub ────────────────────────────────────────────
// WHY: Redis Pub/Sub provides the fan-out needed for real-time chat
// Each chat room is a channel. Messages go to all users in that room.

public class ChatService
{
    private readonly ISubscriber _subscriber;

    // Join a chat room (subscribe to its channel)
    public async Task JoinRoomAsync(string roomId, Func<ChatMessage, Task> onMessage)
    {
        await _subscriber.SubscribeAsync(
            RedisChannel.Literal($"chat:room:{roomId}"),
            async (_, message) =>
            {
                var chatMsg = JsonSerializer.Deserialize<ChatMessage>(message.ToString()!);
                await onMessage(chatMsg!);
            });
    }

    // Send a message to a room
    public async Task SendMessageAsync(string roomId, ChatMessage message)
    {
        await _subscriber.PublishAsync(
            RedisChannel.Literal($"chat:room:{roomId}"),
            JsonSerializer.Serialize(message));

        // WHY: Also store in Redis List for history (Pub/Sub doesn't store messages)
        var db = _subscriber.Multiplexer.GetDatabase();
        await db.ListRightPushAsync($"chat:history:{roomId}", JsonSerializer.Serialize(message));
        await db.ListTrimAsync($"chat:history:{roomId}", -100, -1); // Keep last 100 messages
    }

    // Leave a room
    public async Task LeaveRoomAsync(string roomId)
        => await _subscriber.UnsubscribeAsync(RedisChannel.Literal($"chat:room:{roomId}"));

    // Get message history
    public async Task<IEnumerable<ChatMessage>> GetHistoryAsync(string roomId, int count = 50)
    {
        var db = _subscriber.Multiplexer.GetDatabase();
        var messages = await db.ListRangeAsync($"chat:history:{roomId}", -count, -1);
        return messages.Select(m => JsonSerializer.Deserialize<ChatMessage>(m.ToString()!)!);
    }
}

public record ChatMessage(string RoomId, string UserId, string Username, string Text, DateTime Timestamp);
```

---

### Real-Time Dashboard Updates

```csharp
// WHY: Pub/Sub for pushing metrics to live dashboards avoids polling
public class DashboardPublisher
{
    private readonly ISubscriber _subscriber;

    // Push metric update to all dashboard clients
    public async Task PushMetricAsync(string metricName, object value)
    {
        var update = new
        {
            Metric = metricName,
            Value = value,
            Timestamp = DateTime.UtcNow
        };

        await _subscriber.PublishAsync(
            RedisChannel.Literal("dashboard:metrics"),
            JsonSerializer.Serialize(update));
    }
}

// In a background worker that runs every 5 seconds
public class MetricsCollectorWorker : BackgroundService
{
    private readonly DashboardPublisher _publisher;
    private readonly IMetricsService _metrics;

    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            var snapshot = await _metrics.GetSnapshotAsync(ct);

            await _publisher.PushMetricAsync("active_users", snapshot.ActiveUsers);
            await _publisher.PushMetricAsync("orders_per_min", snapshot.OrdersPerMinute);
            await _publisher.PushMetricAsync("error_rate", snapshot.ErrorRate);

            await Task.Delay(TimeSpan.FromSeconds(5), ct);
        }
    }
}
```

---

## Pub/Sub + SignalR Integration

```
┌────────────────────────────────────────────────────────────────┐
│              REDIS BACKPLANE FOR SIGNALR                       │
│                                                                │
│  Client A ──▶ Server 1 ──▶ Redis Pub/Sub ──▶ Server 2 ──▶ Client B
│                                    │
│                                    └──▶ Server 3 ──▶ Client C │
│                                                                │
│  WHY: Without Redis backplane, SignalR can only send to       │
│  clients connected to the SAME server instance               │
└────────────────────────────────────────────────────────────────┘
```

```csharp
// NuGet: Microsoft.AspNetCore.SignalR.StackExchangeRedis
builder.Services.AddSignalR()
    .AddStackExchangeRedis(
        builder.Configuration.GetConnectionString("Redis")!,
        options =>
        {
            // WHY: Custom prefix prevents conflicts if multiple apps share Redis
            options.Configuration.ChannelPrefix = RedisChannel.Literal("MyApp");
        });

// ── Hub ────────────────────────────────────────────────────────────────
public class NotificationHub : Hub
{
    public async Task JoinGroup(string groupName)
        => await Groups.AddToGroupAsync(Context.ConnectionId, groupName);

    public async Task LeaveGroup(string groupName)
        => await Groups.RemoveFromGroupAsync(Context.ConnectionId, groupName);
}

// ── Sending from non-hub code (e.g., background service) ───────────────
public class OrderShippedHandler
{
    private readonly IHubContext<NotificationHub> _hub;

    public async Task HandleAsync(OrderShippedEvent evt)
    {
        // WHY: IHubContext sends to clients from outside the Hub class
        // Redis backplane ensures it reaches the right server instance
        await _hub.Clients.User(evt.UserId.ToString())
            .SendAsync("OrderShipped", new
            {
                evt.OrderId,
                evt.TrackingNumber,
                EstimatedDelivery = evt.EstimatedDelivery
            });
    }
}
```

---

## Redis Keyspace Notifications

> **Mental Model:** Subscribe to Redis internal events — when keys expire, are deleted, or modified.

```csharp
// ── Enable keyspace notifications in redis.conf ───────────────────────
// notify-keyspace-events "KEA"
// K = keyspace events, E = keyevent events, A = all commands
// Ex = expired events only, g = generic commands (DEL, EXPIRE)

// ── Alternatively via CLI or code ─────────────────────────────────────
await db.ExecuteAsync("CONFIG", "SET", "notify-keyspace-events", "KEg$x");
// K=keyspace, E=keyevent, g=generic, $=string, x=expired

// ── Subscribe to key expiry events ────────────────────────────────────
// WHY: Useful for triggering actions when a Redis key expires
// e.g., session expiry triggers cleanup, TTL-based job scheduling

public class KeyExpiryNotificationService : IHostedService
{
    private readonly ISubscriber _subscriber;

    public async Task StartAsync(CancellationToken ct)
    {
        // Subscribe to all expired key events on database 0
        await _subscriber.SubscribeAsync(
            RedisChannel.Pattern("__keyevent@0__:expired"),
            async (channel, expiredKey) =>
            {
                var key = expiredKey.ToString();

                if (key.StartsWith("session:"))
                {
                    var sessionId = key.Replace("session:", "");
                    await HandleSessionExpiredAsync(sessionId);
                }
                else if (key.StartsWith("lock:"))
                {
                    var lockName = key.Replace("lock:", "");
                    await HandleLockExpiredAsync(lockName);
                }
            });
    }

    private async Task HandleSessionExpiredAsync(string sessionId)
    {
        // Log audit trail, cleanup associated data, send "session expired" notification
        Console.WriteLine($"Session expired: {sessionId}");
    }

    private async Task HandleLockExpiredAsync(string lockName)
    {
        // Alert: lock expired without being explicitly released — possible crash
        Console.WriteLine($"WARNING: Lock expired without release: {lockName}");
    }

    public async Task StopAsync(CancellationToken ct)
        => await _subscriber.UnsubscribeAllAsync();
}
```

---

## Limitations & When NOT to Use Pub/Sub

```
┌────────────────────────────────────────────────────────────────────┐
│                  PUB/SUB LIMITATIONS                               │
├────────────────────────────────────────────────────────────────────┤
│ ❌ No persistence — missed messages are LOST                       │
│    → Use Redis Streams or Service Bus for guaranteed delivery      │
│                                                                    │
│ ❌ No replay — can't re-read past messages                        │
│    → Use Redis Streams for event sourcing / replay                │
│                                                                    │
│ ❌ No consumer groups — can't partition work across consumers     │
│    → Use Redis Streams XREADGROUP for competing consumers          │
│                                                                    │
│ ❌ No dead-letter queue — no handling of failed processing        │
│    → Use Azure Service Bus for enterprise reliability              │
│                                                                    │
│ ❌ Fire-and-forget — publisher doesn't know if processing failed  │
│    → Use HTTP callbacks or Service Bus for request-response        │
│                                                                    │
│ ✅ USE Pub/Sub when:                                               │
│    • Cache invalidation (loss tolerable — cache miss = DB hit)    │
│    • Real-time notifications (user notification loss tolerable)    │
│    • Live dashboards (stale for 1 cycle is fine)                  │
│    • Chat (transient, not stored)                                  │
│    • SignalR backplane (built-in retry handles loss)              │
└────────────────────────────────────────────────────────────────────┘
```

---

*Next:* [04-Redis-Distributed-Locking.md](04-Redis-Distributed-Locking.md) — Redlock algorithm, atomic lock operations, deadlock prevention
