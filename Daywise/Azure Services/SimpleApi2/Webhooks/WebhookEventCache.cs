using System.Collections.Concurrent;

namespace Webhooks;

// In-memory idempotency cache for webhook event deduplication.
//
// WHY needed: publishers use at-least-once delivery — the same event can arrive
// multiple times on network failures. This cache ensures each event is processed
// exactly once within the TTL window.
//
// Production upgrade: replace with Redis
//   await db.StringSetAsync($"webhook:seen:{eventId}", "1", TimeSpan.FromHours(24));
//   if the key already existed → duplicate
public sealed class WebhookEventCache
{
    // Key = eventId, Value = expiry time of the record
    private readonly ConcurrentDictionary<string, DateTimeOffset> _seen = new();
    private readonly TimeSpan _ttl = TimeSpan.FromHours(24);
    private DateTimeOffset _lastCleanup = DateTimeOffset.UtcNow;

    // Returns true  → first occurrence, caller should process the event.
    // Returns false → duplicate, caller should acknowledge but skip processing.
    public bool TryMarkSeen(string eventId)
    {
        var now = DateTimeOffset.UtcNow;
        CleanupIfNeeded(now);

        if (_seen.ContainsKey(eventId))
            return false;  // already seen — duplicate

        _seen[eventId] = now.Add(_ttl);
        return true;  // first time — process it
    }

    // Periodic cleanup runs every 10 minutes to avoid unbounded memory growth.
    // WHY not on every call: ConcurrentDictionary iteration is O(n), too expensive per request.
    private void CleanupIfNeeded(DateTimeOffset now)
    {
        if (now - _lastCleanup < TimeSpan.FromMinutes(10)) return;
        _lastCleanup = now;

        foreach (var kvp in _seen.Where(k => now > k.Value).ToList())
            _seen.TryRemove(kvp.Key, out _);
    }
}
