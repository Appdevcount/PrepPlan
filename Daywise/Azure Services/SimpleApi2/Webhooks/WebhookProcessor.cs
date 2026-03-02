using System.Collections.Concurrent;
using System.Threading.Channels;

namespace Webhooks;

// Background processor — reads webhook events from a Channel<T> and routes them
// to type-specific handlers.
//
// WHY BackgroundService + Channel:
//   - The HTTP handler returns 200 in microseconds (channel write is non-blocking)
//   - Actual processing happens independently, at its own pace
//   - Isolates processing failures from HTTP acknowledgement
//   - Bounded channel (500) applies back-pressure if processing falls behind
public sealed class WebhookProcessor : BackgroundService
{
    private readonly Channel<(WebhookEvent Event, string RawPayload)> _channel =
        Channel.CreateBounded<(WebhookEvent, string)>(
            new BoundedChannelOptions(500)
            {
                FullMode     = BoundedChannelFullMode.Wait,  // back-pressure vs drop
                SingleReader = true,
                SingleWriter = false
            });

    // Bounded in-memory audit log — latest 1000 events (including duplicates)
    // Production: write to an append-only DB table for unlimited history
    private readonly ConcurrentQueue<ReceivedEvent> _auditLog = new();
    private int _stored;
    private const int MaxAuditEntries = 1000;

    private readonly ILogger<WebhookProcessor> _logger;
    public WebhookProcessor(ILogger<WebhookProcessor> logger) => _logger = logger;

    // Called from the HTTP endpoint — fast path, returns immediately
    public async ValueTask EnqueueAsync(
        WebhookEvent evt,
        string rawPayload,
        bool wasDuplicate,
        CancellationToken ct = default)
    {
        // Always record for audit (including duplicates)
        StoreAudit(new ReceivedEvent(evt.Id, evt.Type, DateTimeOffset.UtcNow, rawPayload, wasDuplicate));

        // Duplicates: already stored for audit — skip processing
        if (!wasDuplicate)
            await _channel.Writer.WriteAsync((evt, rawPayload), ct);
    }

    // Exposed for GET /webhook/events endpoint
    public IReadOnlyList<ReceivedEvent> GetAuditLog() => _auditLog.ToArray();

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("WebhookProcessor started — awaiting events");

        await foreach (var (evt, raw) in _channel.Reader.ReadAllAsync(stoppingToken))
        {
            try   { await ProcessAsync(evt); }
            catch (Exception ex) { _logger.LogError(ex, "Error processing event {EventId}", evt.Id); }
        }

        _logger.LogInformation("WebhookProcessor stopped");
    }

    private Task ProcessAsync(WebhookEvent evt)
    {
        _logger.LogInformation(
            "Processing webhook: id={EventId} type={Type} published={Ts}",
            evt.Id, evt.Type, evt.Timestamp);

        // Route to type-specific handler — extend this switch for new event types
        return evt.Type switch
        {
            "weather.fetched" => HandleWeatherFetched(evt),
            "trigger.test"    => HandleTestTrigger(evt),
            _                 => HandleUnknown(evt)
        };
    }

    private Task HandleWeatherFetched(WebhookEvent evt)
    {
        // Production: store in time-series DB, trigger downstream processing, etc.
        _logger.LogInformation("Weather event received from publisher: {Data}", evt.Data.ToString());
        return Task.CompletedTask;
    }

    private Task HandleTestTrigger(WebhookEvent evt)
    {
        _logger.LogInformation("Test trigger received: {Data}", evt.Data.ToString());
        return Task.CompletedTask;
    }

    private Task HandleUnknown(WebhookEvent evt)
    {
        _logger.LogWarning("No handler for event type '{Type}' — event id={EventId}", evt.Type, evt.Id);
        return Task.CompletedTask;
    }

    private void StoreAudit(ReceivedEvent record)
    {
        if (Interlocked.Increment(ref _stored) <= MaxAuditEntries)
            _auditLog.Enqueue(record);
    }
}
