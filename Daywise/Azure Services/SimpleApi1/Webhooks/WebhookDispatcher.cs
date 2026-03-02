using System.Threading.Channels;

namespace Webhooks;

// Outbox pattern using Channel<T> + BackgroundService.
//
// WHY decouple with a channel:
//   - API endpoints call EnqueueAsync() → returns in microseconds
//   - BackgroundService reads from channel → handles retries, timeouts independently
//   - A slow or down subscriber never blocks the API response
//   - Bounded capacity (1000) applies back-pressure instead of unbounded memory growth
//
// Production upgrade: replace Channel with reading from a DB outbox table
// so events survive application restarts.
public sealed class WebhookDispatcher : BackgroundService
{
    private readonly Channel<(WebhookEvent Event, WebhookSubscription Subscription)> _channel =
        Channel.CreateBounded<(WebhookEvent, WebhookSubscription)>(
            new BoundedChannelOptions(1000)
            {
                FullMode     = BoundedChannelFullMode.Wait,  // back-pressure producer when full
                SingleReader = true,                          // only this service reads
                SingleWriter = false                          // multiple API threads can write
            });

    private readonly IWebhookPublisher _publisher;
    private readonly ILogger<WebhookDispatcher> _logger;

    public WebhookDispatcher(IWebhookPublisher publisher, ILogger<WebhookDispatcher> logger)
    {
        _publisher = publisher;
        _logger    = logger;
    }

    // Called by API endpoints — fast, non-blocking
    public async ValueTask EnqueueAsync(
        WebhookEvent evt,
        WebhookSubscription sub,
        CancellationToken ct = default)
    {
        await _channel.Writer.WriteAsync((evt, sub), ct);
        _logger.LogDebug("Enqueued webhook: eventId={EventId} type={Type} → {Url}",
            evt.Id, evt.Type, sub.Url);
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("WebhookDispatcher started — processing queued deliveries");

        await foreach (var (evt, sub) in _channel.Reader.ReadAllAsync(stoppingToken))
        {
            // Each delivery runs in its own Task so one slow subscriber
            // doesn't block deliveries to other subscribers
            _ = Task.Run(() => _publisher.PublishAsync(evt, sub, stoppingToken), stoppingToken);
        }

        _logger.LogInformation("WebhookDispatcher stopped");
    }
}
