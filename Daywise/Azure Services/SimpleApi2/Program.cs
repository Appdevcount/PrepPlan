using System.Text;
using System.Text.Json;
using Webhooks;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();

// ── Webhook services ────────────────────────────────────────────────────────
builder.Services.AddSingleton<WebhookSignatureValidator>();
builder.Services.AddSingleton<WebhookEventCache>();
builder.Services.AddSingleton<WebhookProcessor>();
// Register processor as hosted BackgroundService so it starts with the app
builder.Services.AddHostedService(sp => sp.GetRequiredService<WebhookProcessor>());

var app = builder.Build();

app.MapOpenApi();

// app.UseHttpsRedirection();  // disabled — sits behind reverse proxy

// ── Health / Info ────────────────────────────────────────────────────────────
app.MapGet("/health", () => Results.Ok(new { status = "healthy", timestamp = DateTime.UtcNow }))
   .WithName("Health");

app.MapGet("/hello/{name?}", (string? name) =>
    Results.Ok(new { message = $"Hello, {name ?? "World"}!", from = "SimpleApi2 (Handler)" }))
   .WithName("Hello");

app.MapGet("/info", () => Results.Ok(new
{
    machineName   = Environment.MachineName,
    osVersion     = Environment.OSVersion.VersionString,
    dotnetVersion = Environment.Version.ToString(),
    environment   = app.Environment.EnvironmentName,
    role          = "Webhook Handler"
}))
.WithName("Info");

// ── Webhook Receiver ─────────────────────────────────────────────────────────
// Best practices implemented here:
//   1. Read raw body BEFORE deserialization (signature covers raw bytes)
//   2. Validate signature FIRST — reject immediately if invalid
//   3. Validate timestamp — reject replays older than 5 minutes
//   4. Deduplicate using event ID — at-least-once delivery protection
//   5. Return 200 immediately — enqueue for async background processing
//   6. Never reveal WHY signature failed (security: don't help attackers)
app.MapPost("/webhook/receive", async (
    HttpRequest              req,
    WebhookSignatureValidator validator,
    WebhookEventCache         cache,
    WebhookProcessor          processor,
    ILogger<Program>          logger) =>
{
    // ── 1. Read raw body (before any deserialization) ────────────────────────
    // WHY: HttpRequest.Body is a forward-only stream. If we deserialize first,
    // the bytes are consumed and we cannot compute HMAC over them.
    using var ms = new MemoryStream();
    await req.Body.CopyToAsync(ms);
    var rawBytes   = ms.ToArray();
    var rawPayload = Encoding.UTF8.GetString(rawBytes);

    // ── 2. Validate signature ────────────────────────────────────────────────
    var validation = validator.Validate(req.Headers, rawBytes);
    if (!validation.IsValid)
    {
        // Log internally but don't expose the reason externally
        // WHY: detailed errors help attackers understand what to fix
        logger.LogWarning("Webhook rejected — {Reason}", validation.Error);
        return Results.Unauthorized();
    }

    // ── 3. Deserialize payload ───────────────────────────────────────────────
    WebhookEvent? evt;
    try
    {
        evt = JsonSerializer.Deserialize<WebhookEvent>(rawPayload, WebhookJsonOptions.Default);
        if (evt is null) return Results.BadRequest(new { error = "Empty payload" });
    }
    catch (JsonException ex)
    {
        logger.LogWarning(ex, "Webhook payload deserialization failed");
        return Results.BadRequest(new { error = "Invalid JSON" });
    }

    // ── 4. Deduplicate ───────────────────────────────────────────────────────
    var isNew = cache.TryMarkSeen(evt.Id);
    if (!isNew)
    {
        logger.LogInformation("Duplicate webhook ignored: eventId={EventId} type={Type}",
            evt.Id, evt.Type);
        // Return 200 (not 409) — publisher should stop retrying for this event
        return Results.Ok(new { status = "duplicate", eventId = evt.Id });
    }

    // ── 5. Enqueue for async processing — return 200 immediately ────────────
    // WHY: publishers timeout in 5–30s. Doing real work here risks triggering retries.
    await processor.EnqueueAsync(evt, rawPayload, wasDuplicate: false);

    logger.LogInformation("Webhook accepted: eventId={EventId} type={Type}", evt.Id, evt.Type);
    return Results.Ok(new { status = "accepted", eventId = evt.Id });
})
.WithName("ReceiveWebhook");

// ── Webhook Audit Log ─────────────────────────────────────────────────────────
// View all received events — includes duplicates flagged accordingly.
// Production: add auth; return paginated results from DB.
app.MapGet("/webhook/events", (WebhookProcessor processor) =>
    Results.Ok(processor.GetAuditLog()))
.WithName("WebhookEvents");

// ── Weather Forecast (existing endpoint kept as-is) ──────────────────────────
var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast(
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        )).ToArray();
    return forecast;
})
.WithName("GetWeatherForecast");

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
