var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();

var app = builder.Build();

app.MapOpenApi();

// Remove HTTPS redirect — containers sit behind a reverse proxy/load balancer
// app.UseHttpsRedirection();

// --- Health check ---
app.MapGet("/health", () => Results.Ok(new { status = "healthy", timestamp = DateTime.UtcNow }))
   .WithName("Health");

// --- Hello endpoint ---
app.MapGet("/hello/{name?}", (string? name) =>
    Results.Ok(new { message = $"Hello, {name ?? "World"}!", from = "SimpleApi" }))
   .WithName("Hello");

// --- Environment info (useful for Docker experiments) ---
app.MapGet("/info", () => Results.Ok(new
{
    machineName   = Environment.MachineName,
    osVersion     = Environment.OSVersion.VersionString,
    dotnetVersion = Environment.Version.ToString(),
    environment   = app.Environment.EnvironmentName
}))
.WithName("Info");

// --- Original weather forecast ---
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
