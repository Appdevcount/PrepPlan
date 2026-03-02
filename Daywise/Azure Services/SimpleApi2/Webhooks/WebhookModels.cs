using System.Text.Json;
using System.Text.Json.Serialization;

namespace Webhooks;

// Mirrors the publisher's WebhookEvent envelope.
// Data is JsonElement — flexible, zero-allocation representation of any JSON structure.
public record WebhookEvent(
    string         Id,
    string         Type,
    DateTimeOffset Timestamp,
    JsonElement    Data         // raw JSON — route to type-specific handlers
);

// Audit record — every received event (including duplicates) is stored here.
// Production: persist to an append-only database table.
public record ReceivedEvent(
    string         Id,
    string         Type,
    DateTimeOffset ReceivedAt,
    string         RawPayload,
    bool           WasDuplicate
);

// Shared JSON options — must match the publisher (camelCase).
internal static class WebhookJsonOptions
{
    public static readonly JsonSerializerOptions Default = new()
    {
        PropertyNamingPolicy        = JsonNamingPolicy.CamelCase,
        PropertyNameCaseInsensitive = true   // tolerate minor sender variations
    };
}
