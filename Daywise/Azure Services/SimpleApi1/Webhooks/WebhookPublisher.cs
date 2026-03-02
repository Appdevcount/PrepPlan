using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace Webhooks;

public interface IWebhookPublisher
{
    Task PublishAsync(WebhookEvent evt, WebhookSubscription sub, CancellationToken ct = default);
}

public sealed class WebhookPublisher(
    IHttpClientFactory httpClientFactory,
    ILogger<WebhookPublisher> logger) : IWebhookPublisher
{
    // Retry schedule: immediate → 30s → 5min → dead-letter
    // WHY: gives the receiver time to recover from transient failures
    private static readonly TimeSpan[] RetryDelays =
        [TimeSpan.Zero, TimeSpan.FromSeconds(30), TimeSpan.FromMinutes(5)];

    public async Task PublishAsync(WebhookEvent evt, WebhookSubscription sub, CancellationToken ct = default)
    {
        var payload   = JsonSerializer.Serialize(evt, WebhookJsonOptions.Default);
        var signature = ComputeSignature(sub.Secret, payload);

        for (int attempt = 0; attempt < RetryDelays.Length; attempt++)
        {
            if (attempt > 0)
            {
                logger.LogInformation(
                    "Webhook retry {Attempt} for event {EventId} → {Url} (delay: {Delay})",
                    attempt, evt.Id, sub.Url, RetryDelays[attempt]);
                await Task.Delay(RetryDelays[attempt], ct);
            }

            try
            {
                using var request = new HttpRequestMessage(HttpMethod.Post, sub.Url)
                {
                    Content = new StringContent(payload, Encoding.UTF8, "application/json")
                };

                // Standard webhook headers — receiver uses these for routing + validation
                request.Headers.Add("X-Webhook-Event",     evt.Type);
                request.Headers.Add("X-Webhook-Id",        evt.Id);
                request.Headers.Add("X-Webhook-Timestamp", evt.Timestamp.ToUnixTimeSeconds().ToString());
                request.Headers.Add("X-Webhook-Signature", signature);
                request.Headers.Add("User-Agent",          "SimpleApi1-Webhook/1.0");

                var client = httpClientFactory.CreateClient("WebhookClient");
                using var response = await client.SendAsync(request, ct);

                if (response.IsSuccessStatusCode)
                {
                    logger.LogInformation(
                        "Webhook delivered: eventId={EventId} type={Type} url={Url} status={Status}",
                        evt.Id, evt.Type, sub.Url, (int)response.StatusCode);
                    return; // success — stop retrying
                }

                // 4xx (except 429) = permanent failure — receiver explicitly rejected it
                if ((int)response.StatusCode is >= 400 and < 500
                    && response.StatusCode != HttpStatusCode.TooManyRequests)
                {
                    logger.LogWarning(
                        "Webhook permanent failure: eventId={EventId} status={Status} — stopping retries",
                        evt.Id, (int)response.StatusCode);
                    return;
                }

                logger.LogWarning(
                    "Webhook transient failure: eventId={EventId} attempt={Attempt} status={Status}",
                    evt.Id, attempt + 1, (int)response.StatusCode);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                logger.LogError(ex,
                    "Webhook exception: eventId={EventId} attempt={Attempt} url={Url}",
                    evt.Id, attempt + 1, sub.Url);
            }
        }

        // All retries exhausted — move to dead-letter
        // Production: write to Service Bus dead-letter / DB table / alert ops
        logger.LogError(
            "Webhook dead-lettered: eventId={EventId} url={Url} — all {Max} retries exhausted",
            evt.Id, sub.Url, RetryDelays.Length);
    }

    // HMAC-SHA256: industry-standard webhook signature scheme.
    // WHY "sha256=" prefix: allows future algorithm migration without breaking receivers.
    private static string ComputeSignature(string secret, string payload)
    {
        var key  = Encoding.UTF8.GetBytes(secret);
        var data = Encoding.UTF8.GetBytes(payload);
        using var hmac = new HMACSHA256(key);
        var hash = hmac.ComputeHash(data);
        return "sha256=" + Convert.ToHexString(hash).ToLowerInvariant();
    }
}

// Shared JSON options — must be consistent across publisher and receiver.
// WHY camelCase: JSON convention; WHY no indent: minimises payload size.
internal static class WebhookJsonOptions
{
    public static readonly JsonSerializerOptions Default = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented        = false
    };
}
