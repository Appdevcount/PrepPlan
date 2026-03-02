namespace Webhooks;

// ─────────────── Event Envelope ───────────────────────────────────────────
// Every webhook delivery wraps the payload in this standard shape.
// The receiver uses this shape to route and deduplicate.
public record WebhookEvent(
    string         Id,          // globally unique — receiver's idempotency key
    string         Type,        // namespaced event type: "weather.fetched"
    DateTimeOffset Timestamp,   // UTC time of event creation
    object?        Data         // event-specific payload — any .NET object
);

// ─────────────── Registered Subscriber ────────────────────────────────────
public record WebhookSubscription(
    string         Id,
    string         Url,         // where to POST events
    string         Secret,      // HMAC-SHA256 signing key — never log this
    string[]       EventTypes,  // ["*"] = all events, or ["weather.fetched"]
    DateTimeOffset RegisteredAt
);

// ─────────────── Request DTOs ─────────────────────────────────────────────
public record SubscribeRequest(
    string    Url,
    string    Secret,
    string[]? EventTypes  // optional — defaults to ["*"] (all events)
);

public record TriggerRequest(
    string  EventType,
    object? Data          // optional custom payload for the test event
);
