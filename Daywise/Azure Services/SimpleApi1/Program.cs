using Webhooks;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();

// ── Webhook services ────────────────────────────────────────────────────────
// Singleton: one registry and dispatcher shared across all requests
builder.Services.AddSingleton<WebhookRegistry>();
builder.Services.AddSingleton<IWebhookPublisher, WebhookPublisher>();
builder.Services.AddSingleton<WebhookDispatcher>();
// Register dispatcher as the hosted BackgroundService so it starts with the app
builder.Services.AddHostedService(sp => sp.GetRequiredService<WebhookDispatcher>());

// Named HttpClient for webhook delivery — 15s hard timeout per attempt
builder.Services.AddHttpClient("WebhookClient", client =>
{
    client.Timeout = TimeSpan.FromSeconds(15);
});

var app = builder.Build();

app.MapOpenApi();

// app.UseHttpsRedirection();  // disabled — sits behind reverse proxy

// ── Health / Info ────────────────────────────────────────────────────────────
app.MapGet("/health", () => Results.Ok(new { status = "healthy", timestamp = DateTime.UtcNow }))
   .WithName("Health");

app.MapGet("/hello/{name?}", (string? name) =>
    Results.Ok(new { message = $"Hello, {name ?? "World"}!", from = "SimpleApi1 (Publisher)" }))
   .WithName("Hello");

app.MapGet("/info", () => Results.Ok(new
{
    machineName   = Environment.MachineName,
    osVersion     = Environment.OSVersion.VersionString,
    dotnetVersion = Environment.Version.ToString(),
    environment   = app.Environment.EnvironmentName,
    role          = "Webhook Publisher"
}))
.WithName("Info");

// ── Webhook Subscription Management ─────────────────────────────────────────

// Register a new subscriber — provide the URL where events should be delivered,
// the shared secret for HMAC-SHA256 signing, and which event types to receive.
app.MapPost("/webhooks/subscribe", (SubscribeRequest req, WebhookRegistry registry) =>
{
    // Basic URL validation — production should also block RFC-1918 ranges (SSRF)
    if (!Uri.TryCreate(req.Url, UriKind.Absolute, out var uri)
        || (uri.Scheme != "http" && uri.Scheme != "https"))
        return Results.BadRequest(new { error = "Invalid URL — must be http or https" });

    if (string.IsNullOrWhiteSpace(req.Secret) || req.Secret.Length < 16)
        return Results.BadRequest(new { error = "Secret must be at least 16 characters" });

    var sub = registry.Register(req.Url, req.Secret, req.EventTypes ?? ["*"]);

    // Return the subscription with the secret masked — never echo secrets in responses
    return Results.Created($"/webhooks/subscriptions/{sub.Id}", sub with { Secret = "***" });
})
.WithName("Subscribe");

// List all active subscriptions (secrets masked)
app.MapGet("/webhooks/subscriptions", (WebhookRegistry registry) =>
    Results.Ok(registry.GetAll().Select(s => s with { Secret = "***" })))
.WithName("ListSubscriptions");

// Unregister a subscriber by ID
app.MapDelete("/webhooks/subscriptions/{id}", (string id, WebhookRegistry registry) =>
    registry.Unregister(id) ? Results.NoContent() : Results.NotFound())
.WithName("Unsubscribe");

// ── Webhook Trigger (manual test) ────────────────────────────────────────────
// Fire any event type with custom data — useful for testing the end-to-end flow
app.MapPost("/webhooks/trigger", async (
    TriggerRequest req,
    WebhookRegistry registry,
    WebhookDispatcher dispatcher) =>
{
    var evt = new WebhookEvent(
        Id:        Guid.NewGuid().ToString("N"),
        Type:      req.EventType,
        Timestamp: DateTimeOffset.UtcNow,
        Data:      req.Data ?? new { message = "test trigger" }
    );

    var subscribers = registry.GetForEvent(req.EventType);
    foreach (var sub in subscribers)
        await dispatcher.EnqueueAsync(evt, sub);

    return Results.Accepted(
        value: new
        {
            eventId          = evt.Id,
            eventType        = evt.Type,
            deliveriesQueued = subscribers.Count
        });
})
.WithName("TriggerWebhook");

// ── Weather Forecast (publishes webhook on every call) ───────────────────────
var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", async (
    WebhookRegistry registry,
    WebhookDispatcher dispatcher) =>
{
    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast(
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        )).ToArray();

    // Publish "weather.fetched" event to all interested subscribers
    var evt = new WebhookEvent(
        Id:        Guid.NewGuid().ToString("N"),
        Type:      "weather.fetched",
        Timestamp: DateTimeOffset.UtcNow,
        Data:      new { count = forecast.Length, generatedAt = DateTime.UtcNow }
    );

    var subscribers = registry.GetForEvent("weather.fetched");
    foreach (var sub in subscribers)
        await dispatcher.EnqueueAsync(evt, sub);

    return Results.Ok(forecast);
})
.WithName("GetWeatherForecast");

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
