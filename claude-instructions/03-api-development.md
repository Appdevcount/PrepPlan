# 03 — ASP.NET Core API Development

> **Mental Model:** The API layer is a thin translator. It converts HTTP to commands/queries,
> dispatches them to the application layer, and translates results back to HTTP responses.
> No business logic lives here — not even a single `if` about domain rules.

---

## Program.cs — Composition Root Pattern

```csharp
// ── Program.cs ────────────────────────────────────────────────────────────────
// WHY minimal: no Startup.cs, no partial classes. One entry point, clear flow:
//   1. Build services (DI container)
//   2. Build pipeline (middleware order matters — see below)
//   3. Map routes
//   4. Run

var builder = WebApplication.CreateBuilder(args);

// ── Service registration (each layer registers itself) ────────────────────────
builder.Services
    .AddApplicationServices(builder.Configuration)      // Application layer
    .AddInfrastructureServices(builder.Configuration)   // Infrastructure layer
    .AddApiServices(builder.Configuration);             // API layer (Swagger, auth, CORS)

// ── Build the pipeline ────────────────────────────────────────────────────────
var app = builder.Build();

// RULE: Middleware order is critical. Wrong order = security holes or broken behavior.
//
// Correct order:
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseExceptionHandler("/error");   // WHY first after Swagger: catch all unhandled exceptions
app.UseHttpsRedirection();
app.UseCorrelationId();              // custom: adds X-Correlation-Id to every request/response
app.UseRequestLogging();             // logs method, path, status, duration
app.UseAuthentication();             // WHO are you? (JWT validation)
app.UseAuthorization();              // CAN you do this? (policy checks)
app.UseRateLimiter();                // WHY after auth: rate-limit per identity, not per IP

// ── Route mapping ─────────────────────────────────────────────────────────────
app.MapGroup("/api/v1")
    .MapOrderEndpoints()
    .MapCustomerEndpoints()
    .MapHealthEndpoints()
    .RequireAuthorization();         // WHY at group: apply auth to all routes at once

app.Run();
```

---

## Endpoint Groups — Minimal API Pattern

```csharp
// ── OrderEndpoints.cs ─────────────────────────────────────────────────────────
// WHY RouteGroupBuilder: groups related endpoints, applies shared filters/auth once
// WHY static extension method: Program.cs stays clean, each feature owns its routes

public static class OrderEndpoints
{
    public static RouteGroupBuilder MapOrderEndpoints(this RouteGroupBuilder group)
    {
        var orders = group.MapGroup("/orders")
            .WithTags("Orders")                  // Swagger grouping
            .WithOpenApi();

        orders.MapGet(string.Empty, GetAllOrders)
            .WithName("GetAllOrders")
            .Produces<PagedResult<OrderSummaryDto>>(200);

        orders.MapGet("{id:guid}", GetOrderById)
            .WithName("GetOrderById")
            .Produces<OrderDetailDto>(200)
            .Produces(404);

        orders.MapPost(string.Empty, CreateOrder)
            .WithName("CreateOrder")
            .Produces<OrderCreatedDto>(201)
            .Produces<ValidationProblemDetails>(400)
            .RequireAuthorization("OrderWrite");  // specific policy overrides group default

        orders.MapPut("{id:guid}/cancel", CancelOrder)
            .WithName("CancelOrder")
            .Produces(204)
            .Produces(404)
            .Produces(409);

        return group;
    }

    // ── Handlers — minimal, no business logic ─────────────────────────────────

    // WHY IMediator not direct service: decouples endpoint from handler implementation.
    //   Swap implementations without touching this file.
    private static async Task<IResult> GetAllOrders(
        [AsParameters] GetOrdersQuery query,    // WHY AsParameters: bind complex query object from query string
        IMediator mediator,
        CancellationToken ct)
    {
        var result = await mediator.Send(query, ct);
        return Results.Ok(result);
    }

    private static async Task<IResult> GetOrderById(
        Guid id,
        IMediator mediator,
        CancellationToken ct)
    {
        var result = await mediator.Send(new GetOrderByIdQuery(id), ct);

        // Pattern-match on Result<T> — no exceptions cross this boundary
        return result.IsSuccess
            ? Results.Ok(result.Value)
            : Results.NotFound(new { result.Error });
    }

    private static async Task<IResult> CreateOrder(
        CreateOrderRequest request,
        IMediator mediator,
        LinkGenerator links,
        CancellationToken ct)
    {
        var result = await mediator.Send(new PlaceOrderCommand(request), ct);

        if (!result.IsSuccess)
            return Results.BadRequest(new { result.Error });

        // WHY Results.Created with URI: REST convention — 201 includes Location header
        //   pointing to the new resource so the client knows where to find it
        var uri = links.GetPathByName("GetOrderById", new { id = result.Value });
        return Results.Created(uri, new OrderCreatedDto(result.Value));
    }

    private static async Task<IResult> CancelOrder(
        Guid id,
        IMediator mediator,
        CancellationToken ct)
    {
        var result = await mediator.Send(new CancelOrderCommand(id), ct);

        return result switch
        {
            { IsSuccess: true }                  => Results.NoContent(),         // 204
            { Error: "ORDER_NOT_FOUND" }         => Results.NotFound(),           // 404
            { Error: "ORDER_NOT_CANCELLABLE" }   => Results.Conflict(),           // 409
            _                                    => Results.Problem()             // 500
        };
    }
}
```

---

## HTTP Result Conventions

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Operation          │  Success         │  Common Errors                      │
├──────────────────────────────────────────────────────────────────────────────┤
│  GET collection     │  200 OK          │  400 (bad filter), 401, 403         │
│  GET single         │  200 OK          │  404 Not Found, 401, 403            │
│  POST (create)      │  201 Created     │  400 Validation, 409 Conflict       │
│  PUT / PATCH        │  200 OK / 204    │  400, 404, 409 Conflict             │
│  DELETE             │  204 No Content  │  404, 409 (has dependencies)        │
│  POST (action)      │  200 OK          │  400, 404, 409                      │
│  Async operation    │  202 Accepted    │  400, 401, 403                      │
└──────────────────────────────────────────────────────────────────────────────┘

NEVER return:
  - 200 with error details in body (use correct status codes)
  - 500 with stack traces (log internally, return trace ID only)
  - 404 for auth failures (return 403 — 404 leaks resource existence)
```

---

## Request Validation Pipeline

```csharp
// ── Validation happens in Application layer via MediatR pipeline behavior ─────
// WHY: API layer should not contain validation logic. Handler is clean.

// ValidationBehavior.cs (Application layer)
public class ValidationBehavior<TRequest, TResponse>(
    IEnumerable<IValidator<TRequest>> validators)
    : IPipelineBehavior<TRequest, TResponse>
{
    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken ct)
    {
        if (!validators.Any())
            return await next();   // no validators registered for this request — fast path

        // Run all validators in parallel — WHY parallel: independent checks, faster
        var context = new ValidationContext<TRequest>(request);
        var results = await Task.WhenAll(
            validators.Select(v => v.ValidateAsync(context, ct)));

        var failures = results
            .SelectMany(r => r.Errors)
            .Where(f => f is not null)
            .ToList();

        if (failures.Count > 0)
            throw new ValidationException(failures);   // caught by global exception handler → 400

        return await next();
    }
}

// FluentValidation rule — Application layer, not domain
public class CreateOrderCommandValidator : AbstractValidator<CreateOrderCommand>
{
    public CreateOrderCommandValidator()
    {
        RuleFor(x => x.CustomerId)
            .NotEmpty().WithMessage("Customer ID is required");

        RuleFor(x => x.Items)
            .NotEmpty().WithMessage("Order must contain at least one item")
            .Must(items => items.All(i => i.Quantity > 0))
            .WithMessage("All item quantities must be positive");
    }
}
```

---

## Middleware — Correlation ID

```csharp
// WHY correlation ID: every request gets a unique ID. Logs, responses, and
//   downstream services all carry it. Lets you trace one request across
//   multiple services and thousands of log lines.

public class CorrelationIdMiddleware(RequestDelegate next)
{
    private const string HeaderName = "X-Correlation-Id";

    public async Task InvokeAsync(HttpContext ctx)
    {
        // Use incoming ID if provided (from API gateway or upstream service)
        // Generate a new one if this is the origin of the call
        var correlationId = ctx.Request.Headers[HeaderName].FirstOrDefault()
                            ?? Guid.NewGuid().ToString();

        ctx.Items[HeaderName] = correlationId;
        ctx.Response.Headers[HeaderName] = correlationId;   // echo back to client

        // WHY BeginScope: adds correlationId to ALL logs within this request automatically
        using (_logger.BeginScope(new Dictionary<string, object>
               { ["CorrelationId"] = correlationId }))
        {
            await next(ctx);
        }
    }
}
```

---

## API Versioning

```csharp
// WHY version from day one: changing an API without versioning breaks consumers.
//   Add versioning in Program.cs before any routes exist.

builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true;
    // WHY URL versioning: visible in logs, easy to test, clear in bookmarks
    options.ApiVersionReader = ApiVersionReader.Combine(
        new UrlSegmentApiVersionReader(),    // /api/v1/orders
        new HeaderApiVersionReader("X-API-Version")  // X-API-Version: 1.0
    );
});

// Route groups per version
app.MapGroup("/api/v1").HasApiVersion(1, 0).MapOrderEndpoints();
app.MapGroup("/api/v2").HasApiVersion(2, 0).MapOrderEndpointsV2();
```

---

## Health Checks

```csharp
// WHY health checks: AKS liveness/readiness probes use these.
//   Without them, Kubernetes doesn't know if a pod is healthy.

builder.Services.AddHealthChecks()
    .AddDbContextCheck<AppDbContext>("database")              // EF Core ping
    .AddAzureServiceBusTopic(                                 // Service Bus connectivity
        builder.Configuration["ServiceBus:ConnectionString"]!,
        builder.Configuration["ServiceBus:TopicName"]!)
    .AddRedis(builder.Configuration["Redis:ConnectionString"]!, "cache")
    .AddCheck<ExternalApiHealthCheck>("external-api");        // custom check

// Map two endpoints:
// /health/live  — liveness: is the process alive? (basic)
// /health/ready — readiness: can the pod serve traffic? (all dependencies)
app.MapHealthChecks("/health/live", new HealthCheckOptions
{
    Predicate = _ => false   // WHY: liveness checks nothing — just confirms process is alive
});

app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
}).RequireAuthorization("HealthCheck");   // WHY auth: health endpoints reveal infra details
```

---

## Rate Limiting

```csharp
// WHY rate limiting: prevents abuse, protects downstream services, fair usage.
//   Apply per-user after auth, per-IP before auth for unauthenticated endpoints.

builder.Services.AddRateLimiter(opts =>
{
    // Named policy for critical endpoints
    opts.AddSlidingWindowLimiter("api-default", options =>
    {
        options.Window = TimeSpan.FromMinutes(1);
        options.PermitLimit = 100;               // 100 requests per minute
        options.SegmentsPerWindow = 6;           // 6 segments = 10s resolution
        options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        options.QueueLimit = 10;                 // WHY queue: absorb small bursts gracefully
    });

    // WHY 429 not 503: 429 = "you're sending too many requests".
    //   503 = "service unavailable" (server problem, not client problem)
    opts.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

    // Per-user rate limiting (after authentication)
    opts.OnRejected = async (ctx, ct) =>
    {
        ctx.HttpContext.Response.Headers.RetryAfter =
            ((SlidingWindowRateLimiterStatistics?)ctx.Lease.GetAllMetadata()
                .FirstOrDefault(m => m.Key == MetadataName.RetryAfter).Value)
            ?.ToString() ?? "60";   // tell client when to retry
        await ctx.HttpContext.Response.WriteAsJsonAsync(
            new { Error = "Rate limit exceeded. Please retry later." }, ct);
    };
});
```
