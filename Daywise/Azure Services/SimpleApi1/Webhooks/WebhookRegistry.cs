using System.Collections.Concurrent;

namespace Webhooks;

// In-memory subscriber registry.
// Production: replace with a database repository (EF Core / Dapper).
// Singleton — thread-safe via ConcurrentDictionary.
public sealed class WebhookRegistry
{
    private readonly ConcurrentDictionary<string, WebhookSubscription> _subs = new();

    public WebhookSubscription Register(string url, string secret, string[] eventTypes)
    {
        var sub = new WebhookSubscription(
            Id:           Guid.NewGuid().ToString("N"),
            Url:          url,
            Secret:       secret,
            EventTypes:   eventTypes,
            RegisteredAt: DateTimeOffset.UtcNow
        );
        _subs[sub.Id] = sub;
        return sub;
    }

    public bool Unregister(string id) => _subs.TryRemove(id, out _);

    public IReadOnlyList<WebhookSubscription> GetAll() =>
        _subs.Values.ToList().AsReadOnly();

    // Returns subscriptions interested in this specific event type.
    // "*" means the subscriber wants all events.
    public IReadOnlyList<WebhookSubscription> GetForEvent(string eventType) =>
        _subs.Values
             .Where(s => s.EventTypes.Contains("*") || s.EventTypes.Contains(eventType))
             .ToList()
             .AsReadOnly();
}
