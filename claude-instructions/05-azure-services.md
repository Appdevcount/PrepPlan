# 05 — Azure Services Patterns

> **Mental Model:** Azure services are LEGO bricks. Each piece does one thing well.
> Functions = event-triggered compute. Service Bus = reliable message delivery.
> Cosmos DB = globally distributed KV+document store. Key Vault = the locked safe.
> The architecture is about connecting these bricks with the right connectors.

---

## Azure Service Bus — Messaging Patterns

```csharp
// ── Publisher (send messages) ─────────────────────────────────────────────────

// WHY Service Bus over HTTP for inter-service: decoupled, durable, retryable.
//   If the consumer is down, the message waits in the queue — not lost.

public class OrderEventPublisher(ServiceBusClient client, IOptions<ServiceBusOptions> opts)
{
    private readonly ServiceBusSender _sender =
        client.CreateSender(opts.Value.TopicName);

    public async Task PublishOrderPlacedAsync(OrderPlacedEvent evt, CancellationToken ct)
    {
        var message = new ServiceBusMessage(BinaryData.FromObjectAsJson(evt))
        {
            // MessageId ensures idempotent delivery — if the broker retries,
            // the consumer can detect and skip duplicates using this ID
            MessageId       = evt.OrderId.ToString(),
            Subject         = "OrderPlaced",                     // filter key for subscriptions
            ContentType     = "application/json",
            CorrelationId   = Activity.Current?.Id,             // WHY: distributed tracing linkage
            TimeToLive      = TimeSpan.FromHours(24)            // WHY: stale order events have no value
        };

        // ApplicationProperties used in subscription filters (no body deserialization needed)
        message.ApplicationProperties["EventVersion"] = "1.0";
        message.ApplicationProperties["Region"] = opts.Value.Region;

        await _sender.SendMessageAsync(message, ct);
    }
}

// ── Consumer (receive and process messages) ──────────────────────────────────

public class OrderPlacedConsumer(
    ServiceBusClient client,
    IServiceScopeFactory scopeFactory,
    ILogger<OrderPlacedConsumer> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        // WHY ServiceBusProcessor over manual receive loop:
        //   Built-in concurrency, lock renewal, dead-lettering, graceful shutdown.
        var processor = client.CreateProcessor(
            opts.Value.QueueName,
            new ServiceBusProcessorOptions
            {
                MaxConcurrentCalls = 10,   // parallel message processing
                AutoCompleteMessages = false   // WHY false: complete ONLY after successful processing
            });

        processor.ProcessMessageAsync += ProcessMessageAsync;
        processor.ProcessErrorAsync   += ProcessErrorAsync;

        await processor.StartProcessingAsync(ct);
        await Task.Delay(Timeout.Infinite, ct);   // keep alive until cancellation
        await processor.StopProcessingAsync();
    }

    private async Task ProcessMessageAsync(ProcessMessageEventArgs args)
    {
        // WHY new scope per message: processor is Singleton — needs fresh DbContext per message
        using var scope = scopeFactory.CreateScope();
        var handler = scope.ServiceProvider.GetRequiredService<IOrderPlacedHandler>();

        var evt = args.Message.Body.ToObjectFromJson<OrderPlacedEvent>();

        // WHY idempotency check: Service Bus guarantees at-least-once delivery.
        //   The same message CAN be delivered twice (failover, retry).
        //   Processing it twice could double-charge or double-ship.
        if (await handler.IsAlreadyProcessedAsync(args.Message.MessageId))
        {
            logger.LogInformation("Duplicate message {MessageId} — skipping", args.Message.MessageId);
            await args.CompleteMessageAsync(args.Message);   // complete to remove from queue
            return;
        }

        await handler.HandleAsync(evt, args.CancellationToken);

        // Complete ONLY after successful processing — if exception is thrown,
        // the lock expires and the message is retried (up to MaxDeliveryCount times)
        await args.CompleteMessageAsync(args.Message);
    }

    private async Task ProcessErrorAsync(ProcessErrorEventArgs args)
    {
        // WHY not throw here: processor catches exceptions from ProcessMessageAsync
        //   and abandons the message. ProcessErrorAsync is for infrastructure errors.
        logger.LogError(args.Exception, "Service Bus processor error in {Source}",
            args.ErrorSource);
    }
}
```

---

## Azure Functions — Trigger Patterns

```csharp
// ── Service Bus Trigger — process queue messages ─────────────────────────────

public class OrderProcessingFunction(IOrderService orderService)
{
    // WHY ServiceBusTrigger not Timer: messages drive execution, not a clock.
    //   Scale out automatically based on queue depth.
    [Function("ProcessOrder")]
    public async Task RunAsync(
        [ServiceBusTrigger(
            queueName: "%ServiceBus:QueueName%",   // WHY %var%: reads from app settings
            Connection = "ServiceBus:Connection"
        )]
        ServiceBusReceivedMessage message,
        ServiceBusMessageActions messageActions,   // WHY inject: for complete/dead-letter control
        FunctionContext ctx,
        CancellationToken ct)
    {
        var logger = ctx.GetLogger<OrderProcessingFunction>();

        try
        {
            var order = message.Body.ToObjectFromJson<OrderMessage>();
            await orderService.ProcessAsync(order, ct);
            await messageActions.CompleteMessageAsync(message, ct);
        }
        catch (TransientException ex)
        {
            // WHY AbandonMessage: puts it back in the queue for retry
            // DeliveryCount increments — after MaxDeliveryCount, auto dead-lettered
            logger.LogWarning(ex, "Transient error — abandoning for retry");
            await messageActions.AbandonMessageAsync(message, cancellationToken: ct);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Permanent error — dead-lettering message {Id}", message.MessageId);
            await messageActions.DeadLetterMessageAsync(
                message,
                deadLetterReason: "ProcessingFailed",
                deadLetterErrorDescription: ex.Message,
                cancellationToken: ct);
        }
    }
}

// ── HTTP Trigger — serverless API endpoint ────────────────────────────────────

public class GetOrderFunction(IMediator mediator)
{
    [Function("GetOrder")]
    public async Task<HttpResponseData> RunAsync(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "orders/{id}")]
        HttpRequestData req,
        string id,
        FunctionContext ctx,
        CancellationToken ct)
    {
        var result = await mediator.Send(new GetOrderByIdQuery(Guid.Parse(id)), ct);

        var response = req.CreateResponse(
            result.IsSuccess ? HttpStatusCode.OK : HttpStatusCode.NotFound);

        await response.WriteAsJsonAsync(result.IsSuccess ? result.Value : result.Error, ct);
        return response;
    }
}

// ── Timer Trigger — scheduled jobs ────────────────────────────────────────────

public class CleanupFunction(ICleanupService cleanupService)
{
    // WHY Timer: runs on a schedule without needing an always-on server
    [Function("DailyCleanup")]
    public async Task RunAsync(
        [TimerTrigger("0 0 2 * * *")]   // 2 AM daily (CRON: seconds minutes hours ...)
        TimerInfo timer,
        FunctionContext ctx,
        CancellationToken ct)
    {
        if (timer.IsPastDue)   // WHY check: function may have been delayed — avoid stacking
        {
            ctx.GetLogger<CleanupFunction>().LogWarning("Timer is past due — skipping");
            return;
        }

        await cleanupService.CleanupExpiredOrdersAsync(ct);
    }
}
```

---

## Azure Key Vault — Secrets Pattern

```csharp
// ── RULE: No secrets in appsettings.json or environment variables in production.
//    All secrets come from Key Vault. Reference pattern below.

// Program.cs — add Key Vault as a config source
builder.Configuration.AddAzureKeyVault(
    new Uri($"https://{builder.Configuration["KeyVault:Name"]}.vault.azure.net/"),
    // WHY DefaultAzureCredential: works locally (dev login) AND in production (managed identity)
    //   No secret needed to access Key Vault — managed identity is the credential
    new DefaultAzureCredential()
);

// appsettings.json — reference pattern (name matches Key Vault secret name with -- separator)
// {
//   "ConnectionStrings": {
//     "Database": ""          // ← overridden by Key Vault: ConnectionStrings--Database
//   },
//   "ServiceBus": {
//     "ConnectionString": ""  // ← overridden by Key Vault: ServiceBus--ConnectionString
//   }
// }
// WHY -- separator: Key Vault secret names can't have colons. Azure maps -- to : in config.

// ── Accessing secrets in code — via IConfiguration (not KeyVaultClient directly)
// Options pattern automatically picks up the secret via configuration binding:
public class ServiceBusOptions
{
    public string ConnectionString { get; init; } = string.Empty;
    // Value comes from Key Vault: ServiceBus--ConnectionString → ServiceBus:ConnectionString
}
```

---

## Cosmos DB — Pattern Reference

```csharp
// WHY Cosmos DB: globally distributed, multi-model, 99.999% availability SLA,
//   automatic indexing, scale to any throughput. Use for: event stores, session data,
//   product catalogs, leaderboards, real-time personalization.

// ── Container design rules ───────────────────────────────────────────────────
// 1. One container per entity type with high write throughput
// 2. Partition key = most common query predicate (e.g., tenantId, userId)
// 3. Avoid hot partitions — partition key must have high cardinality
// 4. Read your own writes: use Session consistency (default is good)

public class CosmosOrderRepository(CosmosClient client, IOptions<CosmosDbOptions> opts)
    : IOrderRepository
{
    private readonly Container _container =
        client.GetContainer(opts.Value.DatabaseName, opts.Value.OrdersContainer);

    public async Task<Order?> GetByIdAsync(string id, string partitionKey, CancellationToken ct)
    {
        try
        {
            // WHY pass partition key explicitly: Cosmos routes to the right partition.
            //   Without it, Cosmos does a cross-partition scan — expensive.
            var response = await _container.ReadItemAsync<Order>(id, new PartitionKey(partitionKey), cancellationToken: ct);
            return response.Resource;
        }
        catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
        {
            return null;   // WHY catch not throw: Not Found is a valid state, not an exception
        }
    }

    public async Task UpsertAsync(Order order, CancellationToken ct)
    {
        // WHY UpsertItem not CreateItem: idempotent — safe to retry on transient failure
        await _container.UpsertItemAsync(order, new PartitionKey(order.TenantId), cancellationToken: ct);
    }

    public async Task<IReadOnlyList<Order>> QueryByStatusAsync(
        string tenantId, string status, CancellationToken ct)
    {
        // WHY LINQ over raw SQL string: type-safe, refactor-safe
        var query = _container.GetItemLinqQueryable<Order>(
            requestOptions: new QueryRequestOptions
            {
                PartitionKey = new PartitionKey(tenantId),   // WHY: single-partition query — fast
                MaxItemCount = 100                            // page size
            })
            .Where(o => o.Status == status)
            .OrderByDescending(o => o.CreatedAt);

        var results = new List<Order>();
        using var iterator = query.ToFeedIterator();

        while (iterator.HasMoreResults)
        {
            var page = await iterator.ReadNextAsync(ct);
            results.AddRange(page);
        }

        return results;
    }
}
```

---

## Bicep — Infrastructure as Code Pattern

```bicep
// ── RULE: All Azure resources defined in Bicep. No manual portal clicks in production.
// ── RULE: Parameterise environment-specific values. Hard-code immutable values.

// main.bicep — entry point
@description('Environment name (dev/staging/prod)')
@allowed(['dev', 'staging', 'prod'])
param environment string

@description('Azure region')
param location string = resourceGroup().location

// WHY naming convention: consistent names enable automation and cost tagging
var prefix = 'app-${environment}'
var tags = {
  Environment: environment
  ManagedBy: 'Bicep'
  CostCenter: 'Engineering'
}

// ── App Service Plan ──────────────────────────────────────────────────────────
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${prefix}-asp'
  location: location
  tags: tags
  sku: {
    // WHY P1v3 not F1: Free tier has no custom domains, no slots, cold starts
    name: environment == 'prod' ? 'P2v3' : 'P1v3'
    tier: 'PremiumV3'
  }
  properties: {
    reserved: true   // WHY: enables Linux — lower cost than Windows
  }
}

// ── Web App with managed identity ────────────────────────────────────────────
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: '${prefix}-api'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'   // WHY: managed identity — no credentials to rotate/leak
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true          // WHY: never serve over HTTP in any environment
    siteConfig: {
      alwaysOn: environment == 'prod'   // WHY: prevent cold starts in production only
      minTlsVersion: '1.2'
      appSettings: [
        { name: 'ASPNETCORE_ENVIRONMENT', value: environment }
        { name: 'KeyVault__Name',         value: keyVault.name }
        // WHY NOT include secrets here: they come from Key Vault at runtime
      ]
    }
  }
}

// ── Grant web app access to Key Vault ────────────────────────────────────────
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-02-01' = {
  name: '${keyVault.name}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: webApp.identity.principalId   // managed identity object ID
        permissions: {
          secrets: ['get', 'list']   // WHY: minimum permissions (principle of least privilege)
        }
      }
    ]
  }
}
```

---

## Application Insights — Telemetry Pattern

```csharp
// ── Registration ───────────────────────────────────────────────────────────────
builder.Services.AddApplicationInsightsTelemetry(options =>
{
    // WHY DependencyTrackingOptions: auto-instruments HttpClient, SQL, Service Bus
    options.EnableDependencyTrackingTelemetryModule = true;
    options.EnableRequestTrackingTelemetryModule = true;
});

// ── Custom telemetry in code ──────────────────────────────────────────────────
public class OrderService(TelemetryClient telemetry)
{
    public async Task<Order> PlaceOrderAsync(PlaceOrderCommand cmd, CancellationToken ct)
    {
        // WHY StartOperation: creates a span in the distributed trace.
        //   All telemetry inside this using block is a child of the HTTP request span.
        using var operation = telemetry.StartOperation<RequestTelemetry>("PlaceOrder");

        try
        {
            var order = await ProcessOrderAsync(cmd, ct);

            // Custom metric — appears in Application Insights Metrics explorer
            telemetry.TrackMetric("OrderValue", (double)order.Total);

            // Custom event — queryable in Log Analytics
            telemetry.TrackEvent("OrderPlaced", new Dictionary<string, string>
            {
                ["OrderId"]    = order.Id.ToString(),
                ["CustomerId"] = order.CustomerId.ToString(),
                ["ItemCount"]  = order.Items.Count.ToString()
            });

            operation.Telemetry.Success = true;
            return order;
        }
        catch (Exception ex)
        {
            operation.Telemetry.Success = false;
            telemetry.TrackException(ex);
            throw;   // re-throw — don't swallow
        }
    }
}
```
