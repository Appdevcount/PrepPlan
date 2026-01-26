# Day 08: Distributed Systems & Messaging

## Overview
Distributed systems introduce complexity: network failures, partial failures, message ordering, and consistency challenges. This guide covers event-driven architectures, messaging patterns, and handling failures in distributed environments.

---

## 1. Event-Driven Architecture Patterns

### Event Types

```csharp
// 1. Domain Event - Something that happened in the domain
public record OrderPlacedEvent
{
    public Guid OrderId { get; init; }
    public Guid CustomerId { get; init; }
    public List<OrderItem> Items { get; init; }
    public decimal Total { get; init; }
    public DateTime OccurredAt { get; init; }
}

// 2. Integration Event - Cross-service communication
public record CustomerRegisteredIntegrationEvent
{
    public Guid CustomerId { get; init; }
    public string Email { get; init; }
    public DateTime RegisteredAt { get; init; }
}

// 3. Command - Intent to do something (not an event!)
public record PlaceOrderCommand
{
    public Guid CustomerId { get; init; }
    public List<OrderItem> Items { get; init; }
}
```

### Event Notification vs Event-Carried State Transfer

**Architect's Trade-off Decision:**
- **Event Notification**: Smaller messages, source of truth remains centralized, requires callback (coupling)
- **Event-Carried State Transfer**: Larger messages, recipients autonomous (no callback), data duplication
- **Use notification when**: Event size matters, data changes frequently, strong consistency needed
- **Use state transfer when**: Autonomy critical, read-heavy scenarios, network calls expensive

```csharp
// Event Notification - Minimal data, recipients fetch details if needed
public record ProductPriceChangedEvent
{
    public Guid ProductId { get; init; }
    public DateTime ChangedAt { get; init; }
}

// Handler needs to call back to get details
public class ProductCacheInvalidationHandler : IEventHandler<ProductPriceChangedEvent>
{
    private readonly IProductService _productService;
    private readonly ICache _cache;

    public async Task HandleAsync(ProductPriceChangedEvent @event)
    {
        // Need to fetch product details
        var product = await _productService.GetProductAsync(@event.ProductId);
        await _cache.SetAsync($"product:{@event.ProductId}", product);
    }
}

// Event-Carried State Transfer - Contains all data needed
public record ProductPriceChangedEventWithState
{
    public Guid ProductId { get; init; }
    public string ProductName { get; init; }
    public decimal OldPrice { get; init; }
    public decimal NewPrice { get; init; }
    public DateTime ChangedAt { get; init; }
}

// Handler has everything it needs
public class ProductCacheInvalidationHandler : IEventHandler<ProductPriceChangedEventWithState>
{
    private readonly ICache _cache;

    public async Task HandleAsync(ProductPriceChangedEventWithState @event)
    {
        // No need to call back - event contains all data
        var product = new Product
        {
            Id = @event.ProductId,
            Name = @event.ProductName,
            Price = @event.NewPrice
        };
        await _cache.SetAsync($"product:{@event.ProductId}", product);
    }
}
```

**Trade-offs**:
- **Notification**: Smaller messages, but couples services (need to call back)
- **State Transfer**: Self-contained, but larger messages and data duplication

---

## 2. Message Ordering Guarantees

### The Problem

Messages can arrive out of order in distributed systems.

```
Producer sends:
  1. CreateUser(userId: 123, name: "Alice")
  2. UpdateUser(userId: 123, name: "Bob")
  3. DeleteUser(userId: 123)

Consumer receives:
  1. UpdateUser (fails - user doesn't exist!)
  2. CreateUser
  3. DeleteUser

Final state: User exists (should be deleted!)
```

### Solution 1: Partition Key (Same Partition = Ordered)

```csharp
// Azure Service Bus
await sender.SendMessageAsync(new ServiceBusMessage
{
    Body = BinaryData.FromObjectAsJson(userCreatedEvent),
    PartitionKey = userId.ToString() // All messages for same user go to same partition
});

// All messages with same partition key are processed in order
```

### Solution 2: Sequence Number

```csharp
public record UserEvent
{
    public Guid UserId { get; init; }
    public long SequenceNumber { get; init; } // Incrementing sequence
    public string EventType { get; init; }
    public DateTime OccurredAt { get; init; }
}

public class UserEventHandler
{
    private readonly IDistributedCache _cache;

    public async Task HandleAsync(UserEvent @event)
    {
        var key = $"user:sequence:{@event.UserId}";
        var lastSequenceStr = await _cache.GetStringAsync(key);
        var lastSequence = lastSequenceStr != null ? long.Parse(lastSequenceStr) : 0;

        if (@event.SequenceNumber <= lastSequence)
        {
            // Out of order or duplicate - ignore
            return;
        }

        if (@event.SequenceNumber > lastSequence + 1)
        {
            // Missing events - wait or fetch missing events
            await HandleMissingEventsAsync(@event.UserId, lastSequence, @event.SequenceNumber);
        }

        // Process event
        await ProcessEventAsync(@event);

        // Update last processed sequence
        await _cache.SetStringAsync(key, @event.SequenceNumber.ToString());
    }

    private async Task HandleMissingEventsAsync(Guid userId, long lastSequence, long currentSequence)
    {
        // Fetch missing events from event store
        for (long seq = lastSequence + 1; seq < currentSequence; seq++)
        {
            var missingEvent = await _eventStore.GetEventAsync(userId, seq);
            await ProcessEventAsync(missingEvent);
        }
    }
}
```

### Solution 3: Idempotent Processing (Order Doesn't Matter)

```csharp
// Make operations idempotent so order doesn't matter
public class UserEventHandler
{
    public async Task HandleAsync(UserCreatedEvent @event)
    {
        // Upsert - works even if received multiple times or out of order
        await _repository.UpsertAsync(new User
        {
            Id = @event.UserId,
            Name = @event.Name,
            Email = @event.Email,
            CreatedAt = @event.OccurredAt
        });
    }

    public async Task HandleAsync(UserDeletedEvent @event)
    {
        // Idempotent delete - works even if called multiple times
        await _repository.DeleteAsync(@event.UserId);
    }
}
```

---

## 3. Duplicate Message Handling

> **What is Idempotency?**
>
> An operation is **idempotent** if performing it multiple times has the same effect as performing it once. This is critical in distributed systems where messages can be delivered more than once.
>
> **Examples:**
> - **Idempotent**: `SET user.email = "bob@example.com"` - Running twice still results in bob@example.com
> - **NOT Idempotent**: `INCREMENT user.balance BY 100` - Running twice adds $200 instead of $100
> - **Idempotent**: `DELETE FROM orders WHERE id = 123` - Running twice still results in order deleted
> - **NOT Idempotent**: `INSERT INTO orders (...)` - Running twice creates duplicate orders
>
> **Why it matters:**
> - Network failures may cause retries (did the request succeed?)
> - Message brokers guarantee "at least once" delivery, not "exactly once"
> - Client apps may retry on timeout (even though server succeeded)
>
> **Making operations idempotent:**
> - Use unique identifiers (idempotency keys) to detect duplicates
> - Design operations as "set to value" not "change by delta"
> - Store processed message IDs to skip re-processing

### Why Duplicates Happen

1. **At-least-once delivery**: Message broker retries on failure
2. **Network issues**: Producer retries when unsure if message was sent
3. **Consumer crashes**: Message reprocessed after restart

### Solution 1: Idempotency Keys

```csharp
public record OrderCreatedEvent
{
    public Guid EventId { get; init; } // Unique per event instance
    public Guid OrderId { get; init; }
    public decimal Total { get; init; }
}

public class OrderEventHandler
{
    private readonly IDistributedCache _cache;
    private readonly IOrderRepository _repository;

    public async Task HandleAsync(OrderCreatedEvent @event)
    {
        var idempotencyKey = $"processed:event:{@event.EventId}";

        // Check if already processed
        var alreadyProcessed = await _cache.GetStringAsync(idempotencyKey);
        if (alreadyProcessed != null)
        {
            // Duplicate - skip processing
            return;
        }

        // Process event
        await _repository.SaveOrderAsync(new Order
        {
            Id = @event.OrderId,
            Total = @event.Total
        });

        // Mark as processed (TTL = 7 days to handle late duplicates)
        await _cache.SetStringAsync(
            idempotencyKey,
            "processed",
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromDays(7)
            });
    }
}
```

### Solution 2: Database Unique Constraint

```csharp
// Event table with unique constraint
public class ProcessedEvent
{
    public Guid EventId { get; set; } // Primary key or unique index
    public string EventType { get; set; }
    public DateTime ProcessedAt { get; set; }
}

public class OrderEventHandler
{
    private readonly AppDbContext _db;

    public async Task HandleAsync(OrderCreatedEvent @event)
    {
        using var transaction = await _db.Database.BeginTransactionAsync();

        try
        {
            // Try to insert processed event record
            _db.ProcessedEvents.Add(new ProcessedEvent
            {
                EventId = @event.EventId,
                EventType = nameof(OrderCreatedEvent),
                ProcessedAt = DateTime.UtcNow
            });

            // Process the event
            _db.Orders.Add(new Order
            {
                Id = @event.OrderId,
                Total = @event.Total
            });

            await _db.SaveChangesAsync();
            await transaction.CommitAsync();
        }
        catch (DbUpdateException ex) when (ex.IsUniqueConstraintViolation())
        {
            // Duplicate event - already processed
            await transaction.RollbackAsync();
            return;
        }
    }
}
```

### Solution 3: Natural Idempotency

Design operations to be naturally idempotent.

```csharp
// BAD - Not idempotent
public async Task HandleAsync(OrderShippedEvent @event)
{
    var order = await _repository.GetOrderAsync(@event.OrderId);
    order.ShippedCount++; // Duplicate would increment twice!
    await _repository.SaveAsync(order);
}

// GOOD - Idempotent by design
public async Task HandleAsync(OrderShippedEvent @event)
{
    var order = await _repository.GetOrderAsync(@event.OrderId);
    order.Status = OrderStatus.Shipped; // Setting to same value is idempotent
    order.ShippedAt = @event.ShippedAt;
    await _repository.SaveAsync(order);
}
```

---

## 4. Exactly-Once Delivery Myth

### The Truth

**Exactly-once delivery is impossible** in a distributed system.

You can have:
- **At-most-once**: Message might be lost (fire-and-forget)
- **At-least-once**: Message guaranteed delivered, but might be duplicated
- **Exactly-once processing**: Message might be delivered multiple times, but **processed** only once (via idempotency)

```csharp
// "Exactly-once" is actually at-least-once + idempotent processing

// Message Broker: At-least-once delivery
await serviceBus.SendMessageAsync(message);
// This guarantees delivery, but might send duplicates

// Consumer: Idempotent processing
public class MessageHandler
{
    public async Task HandleAsync(Message message)
    {
        // Check if already processed (idempotency)
        if (await _cache.ExistsAsync($"processed:{message.Id}"))
            return;

        // Process message
        await ProcessAsync(message);

        // Mark as processed
        await _cache.SetAsync($"processed:{message.Id}", "true");
    }
}

// Result: Exactly-once processing (even with at-least-once delivery)
```

### Transactional Outbox Pattern

Ensure message is sent exactly when transaction commits.

```csharp
// Problem: Transaction commits but message send fails
public async Task CreateOrderAsync(Order order)
{
    await _db.SaveChangesAsync(); // Transaction commits

    // What if this fails? Order saved but no event!
    await _messageBus.PublishAsync(new OrderCreatedEvent { OrderId = order.Id });
}

// Solution: Outbox pattern
public async Task CreateOrderAsync(Order order)
{
    using var transaction = await _db.Database.BeginTransactionAsync();

    // Save order
    _db.Orders.Add(order);

    // Save event to outbox table (same transaction)
    _db.OutboxMessages.Add(new OutboxMessage
    {
        Id = Guid.NewGuid(),
        EventType = nameof(OrderCreatedEvent),
        Payload = JsonSerializer.Serialize(new OrderCreatedEvent { OrderId = order.Id }),
        CreatedAt = DateTime.UtcNow
    });

    await _db.SaveChangesAsync();
    await transaction.CommitAsync();
    // Both order and event saved atomically
}

// Background worker publishes events from outbox
public class OutboxPublisherWorker : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var messages = await _db.OutboxMessages
                .Where(m => m.PublishedAt == null)
                .OrderBy(m => m.CreatedAt)
                .Take(100)
                .ToListAsync(stoppingToken);

            foreach (var message in messages)
            {
                try
                {
                    await _messageBus.PublishAsync(message.EventType, message.Payload);

                    message.PublishedAt = DateTime.UtcNow;
                    await _db.SaveChangesAsync(stoppingToken);
                }
                catch (Exception ex)
                {
                    // Retry on next iteration
                    _logger.LogError(ex, "Failed to publish message {MessageId}", message.Id);
                }
            }

            await Task.Delay(TimeSpan.FromSeconds(1), stoppingToken);
        }
    }
}
```

---

## 5. Poison Message Handling

**Architect's Strategy:**
1. **Retry with exponential backoff** (transient errors)
2. **Max retry count** (typically 3-5 attempts)
3. **Dead Letter Queue** for messages that can't be processed
4. **Monitoring/Alerting** on DLQ growth
5. **Manual inspection tools** for DLQ analysis

**Don't**: Retry forever - will block the queue and waste resources

### The Problem

A malformed or problematic message causes handler to crash repeatedly.

```
1. Message arrives
2. Handler crashes
3. Message requeued
4. Handler crashes again
5. Message requeued again
... infinite loop, queue blocked!
```

### Solution: Dead Letter Queue (DLQ)

```csharp
// Azure Service Bus configuration
var options = new ServiceBusProcessorOptions
{
    AutoCompleteMessages = false,
    MaxConcurrentCalls = 10,
    MaxAutoLockRenewalDuration = TimeSpan.FromMinutes(5)
};

var processor = client.CreateProcessor(queueName, options);

processor.ProcessMessageAsync += async args =>
{
    try
    {
        var message = args.Message;
        var orderEvent = message.Body.ToObjectFromJson<OrderCreatedEvent>();

        await _handler.HandleAsync(orderEvent);

        // Complete the message (remove from queue)
        await args.CompleteMessageAsync(message);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Failed to process message");

        // Check delivery count
        if (args.Message.DeliveryCount >= 3)
        {
            // Move to dead letter queue after 3 attempts
            await args.DeadLetterMessageAsync(
                args.Message,
                deadLetterReason: "MaxDeliveryCountExceeded",
                deadLetterErrorDescription: ex.Message);
        }
        else
        {
            // Abandon (requeue) for retry
            await args.AbandonMessageAsync(args.Message);
        }
    }
};

await processor.StartProcessingAsync();
```

### Manual Retry with Exponential Backoff

```csharp
public class ResilientMessageHandler
{
    public async Task HandleAsync(ServiceBusReceivedMessage message)
    {
        var deliveryCount = message.DeliveryCount;
        var maxRetries = 5;

        try
        {
            var @event = message.Body.ToObjectFromJson<OrderEvent>();
            await ProcessEventAsync(@event);
            await _receiver.CompleteMessageAsync(message);
        }
        catch (TransientException ex) // Retriable error
        {
            if (deliveryCount < maxRetries)
            {
                // Calculate delay: 2^deliveryCount seconds
                var delay = TimeSpan.FromSeconds(Math.Pow(2, deliveryCount));

                // Schedule retry
                await _receiver.AbandonMessageAsync(message, new Dictionary<string, object>
                {
                    ["RetryAfter"] = DateTime.UtcNow.Add(delay)
                });
            }
            else
            {
                // Max retries exceeded - dead letter
                await _receiver.DeadLetterMessageAsync(message,
                    deadLetterReason: "MaxRetriesExceeded",
                    deadLetterErrorDescription: ex.Message);
            }
        }
        catch (PermanentException ex) // Non-retriable error
        {
            // Immediately dead letter
            await _receiver.DeadLetterMessageAsync(message,
                deadLetterReason: "PermanentError",
                deadLetterErrorDescription: ex.Message);
        }
    }
}
```

### Dead Letter Queue Processor

```csharp
// Monitor and process dead letter queue
public class DeadLetterQueueProcessor : BackgroundService
{
    private readonly ServiceBusReceiver _dlqReceiver;
    private readonly ILogger<DeadLetterQueueProcessor> _logger;

    public DeadLetterQueueProcessor(ServiceBusClient client, ILogger<DeadLetterQueueProcessor> logger)
    {
        _dlqReceiver = client.CreateReceiver(
            queueName,
            new ServiceBusReceiverOptions
            {
                SubQueue = SubQueue.DeadLetter
            });
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var messages = await _dlqReceiver.ReceiveMessagesAsync(10, TimeSpan.FromSeconds(5), stoppingToken);

            foreach (var message in messages)
            {
                _logger.LogWarning(
                    "Dead letter message: {MessageId}, Reason: {Reason}, Description: {Description}",
                    message.MessageId,
                    message.DeadLetterReason,
                    message.DeadLetterErrorDescription);

                // Option 1: Manual inspection and fix
                // Option 2: Republish to original queue after fixing issue
                // Option 3: Store for later analysis
                await StoreForAnalysisAsync(message);

                await _dlqReceiver.CompleteMessageAsync(message, stoppingToken);
            }

            await Task.Delay(TimeSpan.FromSeconds(10), stoppingToken);
        }
    }

    private async Task StoreForAnalysisAsync(ServiceBusReceivedMessage message)
    {
        await _db.DeadLetterMessages.AddAsync(new DeadLetterMessage
        {
            MessageId = message.MessageId,
            Reason = message.DeadLetterReason,
            Description = message.DeadLetterErrorDescription,
            Body = message.Body.ToString(),
            ReceivedAt = DateTime.UtcNow
        });
        await _db.SaveChangesAsync();
    }
}
```

---

## 6. Saga Pattern

> **What is the Saga Pattern?**
>
> A **saga** is a design pattern for managing distributed transactions across multiple microservices where traditional ACID transactions are not possible. Instead of one atomic transaction, a saga breaks the operation into a sequence of local transactions, each with a compensating action to undo it if needed.
>
> **Why do we need Sagas?**
> - In microservices, each service has its own database (no shared transactions)
> - Traditional 2-phase commit (2PC) doesn't scale and creates tight coupling
> - Sagas provide eventual consistency across services
>
> **How it works:**
> ```
> Order Saga: Create Order → Reserve Inventory → Process Payment → Ship Order
>
> If Payment fails:
> 1. Compensate: Release Inventory (undo step 2)
> 2. Compensate: Cancel Order (undo step 1)
> ```
>
> **Key concepts:**
> - **Local Transaction**: Each step is a transaction within one service
> - **Compensating Transaction**: The "undo" action if a later step fails
> - **Semantic Rollback**: Not a true rollback, but a business action that reverses the effect
>
> **Example compensations:**
> - CreateOrder → DeleteOrder (compensation)
> - ReserveInventory → ReleaseInventory (compensation)
> - ChargePayment → RefundPayment (compensation)

### Orchestration vs Choreography

**Tech Lead Decision Matrix:**

| Factor | Orchestration | Choreography |
|--------|--------------|--------------|
| Complexity | Centralized logic, easier to reason about | Distributed, harder to visualize flow |
| Coupling | Higher (orchestrator knows all steps) | Lower (services react independently) |
| Observability | Easier (single state machine) | Harder (trace across services) |
| Failure Handling | Centralized retry/compensation | Distributed retry logic |
| Use When | 5+ steps, complex business process | 2-3 steps, highly autonomous services |

**Common Mistake**: Using choreography for complex workflows - difficult to debug and maintain

```
ORCHESTRATION (Central Coordinator)
┌──────────────────┐
│ Order Saga       │
│ (Coordinator)    │
└────────┬─────────┘
         │
    ┌────┼────┬────────┐
    │    │    │        │
┌───▼┐ ┌─▼──┐ ┌▼─────┐ ┌▼──────┐
│Inv.│ │Pay │ │Ship  │ │Email  │
└────┘ └────┘ └──────┘ └───────┘

CHOREOGRAPHY (Event-Driven)
┌──────┐ OrderCreated  ┌─────────┐
│Order │──────────────▶│Inventory│
└──────┘               └────┬────┘
                            │ InventoryReserved
                       ┌────▼───┐
                       │Payment │
                       └────┬───┘
                            │ PaymentProcessed
                       ┌────▼────┐
                       │Shipping │
                       └─────────┘
```

### Orchestration (State Machine)

**Use when**: Complex workflow, clear business process, need visibility

```csharp
// Saga state
public enum OrderSagaState
{
    Started,
    InventoryReserved,
    PaymentProcessed,
    Completed,
    Failed
}

public class OrderSaga
{
    public Guid Id { get; set; }
    public Guid OrderId { get; set; }
    public OrderSagaState State { get; set; }
    public DateTime StartedAt { get; set; }
    public string FailureReason { get; set; }
}

// Saga orchestrator
public class OrderSagaOrchestrator
{
    private readonly IInventoryService _inventory;
    private readonly IPaymentService _payment;
    private readonly IShippingService _shipping;
    private readonly ISagaRepository _sagaRepo;

    public async Task ExecuteAsync(Guid orderId)
    {
        // Create saga instance
        var saga = new OrderSaga
        {
            Id = Guid.NewGuid(),
            OrderId = orderId,
            State = OrderSagaState.Started,
            StartedAt = DateTime.UtcNow
        };
        await _sagaRepo.SaveAsync(saga);

        try
        {
            // Step 1: Reserve inventory
            await _inventory.ReserveAsync(orderId);
            saga.State = OrderSagaState.InventoryReserved;
            await _sagaRepo.SaveAsync(saga);

            // Step 2: Process payment
            await _payment.ChargeAsync(orderId);
            saga.State = OrderSagaState.PaymentProcessed;
            await _sagaRepo.SaveAsync(saga);

            // Step 3: Create shipment
            await _shipping.CreateShipmentAsync(orderId);
            saga.State = OrderSagaState.Completed;
            await _sagaRepo.SaveAsync(saga);
        }
        catch (Exception ex)
        {
            // Compensate based on current state
            saga.State = OrderSagaState.Failed;
            saga.FailureReason = ex.Message;
            await _sagaRepo.SaveAsync(saga);

            await CompensateAsync(saga);
        }
    }

    private async Task CompensateAsync(OrderSaga saga)
    {
        // Rollback in reverse order
        if (saga.State >= OrderSagaState.PaymentProcessed)
        {
            await _payment.RefundAsync(saga.OrderId);
        }

        if (saga.State >= OrderSagaState.InventoryReserved)
        {
            await _inventory.ReleaseAsync(saga.OrderId);
        }
    }
}
```

### Choreography (Event-Driven)

**Use when**: Loose coupling preferred, independent services, simple workflow

```csharp
// Step 1: Order Service
public class OrderService
{
    public async Task CreateOrderAsync(CreateOrderRequest request)
    {
        var order = new Order { Id = Guid.NewGuid(), Status = OrderStatus.Pending };
        await _repository.SaveAsync(order);

        // Publish event - don't call inventory directly
        await _bus.PublishAsync(new OrderCreatedEvent
        {
            OrderId = order.Id,
            Items = request.Items
        });
    }
}

// Step 2: Inventory Service (listens to OrderCreated)
public class OrderCreatedHandler : IEventHandler<OrderCreatedEvent>
{
    public async Task HandleAsync(OrderCreatedEvent @event)
    {
        try
        {
            await _inventory.ReserveAsync(@event.OrderId, @event.Items);

            // Publish next event
            await _bus.PublishAsync(new InventoryReservedEvent
            {
                OrderId = @event.OrderId,
                ReservedAt = DateTime.UtcNow
            });
        }
        catch (InsufficientStockException ex)
        {
            // Publish failure event
            await _bus.PublishAsync(new InventoryReservationFailedEvent
            {
                OrderId = @event.OrderId,
                Reason = ex.Message
            });
        }
    }
}

// Step 3: Payment Service (listens to InventoryReserved)
public class InventoryReservedHandler : IEventHandler<InventoryReservedEvent>
{
    public async Task HandleAsync(InventoryReservedEvent @event)
    {
        try
        {
            var result = await _payment.ChargeAsync(@event.OrderId);

            await _bus.PublishAsync(new PaymentProcessedEvent
            {
                OrderId = @event.OrderId,
                TransactionId = result.TransactionId
            });
        }
        catch (PaymentFailedException ex)
        {
            // Publish failure - triggers compensation
            await _bus.PublishAsync(new PaymentFailedEvent
            {
                OrderId = @event.OrderId,
                Reason = ex.Message
            });
        }
    }
}

// Step 4: Inventory Service (listens to PaymentFailed for compensation)
public class PaymentFailedHandler : IEventHandler<PaymentFailedEvent>
{
    public async Task HandleAsync(PaymentFailedEvent @event)
    {
        // Compensate - release inventory
        await _inventory.ReleaseAsync(@event.OrderId);

        await _bus.PublishAsync(new InventoryReleasedEvent
        {
            OrderId = @event.OrderId
        });
    }
}

// Step 5: Order Service (listens to all outcomes)
public class OrderStatusUpdateHandler :
    IEventHandler<PaymentProcessedEvent>,
    IEventHandler<PaymentFailedEvent>
{
    public async Task HandleAsync(PaymentProcessedEvent @event)
    {
        var order = await _repository.GetAsync(@event.OrderId);
        order.Status = OrderStatus.Paid;
        await _repository.SaveAsync(order);
    }

    public async Task HandleAsync(PaymentFailedEvent @event)
    {
        var order = await _repository.GetAsync(@event.OrderId);
        order.Status = OrderStatus.Failed;
        order.FailureReason = @event.Reason;
        await _repository.SaveAsync(order);
    }
}
```

**Choreography Pros**: Loose coupling, resilient, scalable
**Choreography Cons**: Hard to understand full flow, no central visibility

---

## 7. Compensating Transactions

### The Problem

Can't rollback distributed transactions - need to "undo" via compensating actions.

```csharp
// Forward transaction
public async Task BookFlightAsync(BookingRequest request)
{
    await _flights.ReserveAsync(request.FlightId);
    await _hotels.ReserveAsync(request.HotelId);
    await _payment.ChargeAsync(request.Amount);
}

// If payment fails, need to compensate (release reservations)
public async Task CompensateAsync(Guid bookingId)
{
    // Execute in reverse order
    // Payment already failed, so skip

    // Release hotel
    await _hotels.CancelReservationAsync(bookingId);

    // Release flight
    await _flights.CancelReservationAsync(bookingId);
}
```

### Implementing Compensations

```csharp
public interface ISagaStep
{
    Task ExecuteAsync(SagaContext context);
    Task CompensateAsync(SagaContext context);
}

public class ReserveInventoryStep : ISagaStep
{
    private readonly IInventoryService _inventory;

    public async Task ExecuteAsync(SagaContext context)
    {
        await _inventory.ReserveAsync(context.OrderId, context.Items);
        context.Data["InventoryReserved"] = true;
    }

    public async Task CompensateAsync(SagaContext context)
    {
        if (context.Data.ContainsKey("InventoryReserved"))
        {
            await _inventory.ReleaseAsync(context.OrderId);
        }
    }
}

public class ProcessPaymentStep : ISagaStep
{
    private readonly IPaymentService _payment;

    public async Task ExecuteAsync(SagaContext context)
    {
        var result = await _payment.ChargeAsync(context.Amount);
        context.Data["TransactionId"] = result.TransactionId;
    }

    public async Task CompensateAsync(SagaContext context)
    {
        if (context.Data.TryGetValue("TransactionId", out var txnId))
        {
            await _payment.RefundAsync(txnId.ToString());
        }
    }
}

// Saga executor
public class SagaExecutor
{
    public async Task ExecuteAsync(List<ISagaStep> steps, SagaContext context)
    {
        var executedSteps = new Stack<ISagaStep>();

        try
        {
            foreach (var step in steps)
            {
                await step.ExecuteAsync(context);
                executedSteps.Push(step);
            }
        }
        catch (Exception ex)
        {
            // Compensate in reverse order
            while (executedSteps.Count > 0)
            {
                var step = executedSteps.Pop();
                try
                {
                    await step.CompensateAsync(context);
                }
                catch (Exception compensationEx)
                {
                    // Log compensation failure - may need manual intervention
                    _logger.LogError(compensationEx,
                        "Compensation failed for {StepType}", step.GetType().Name);
                }
            }

            throw;
        }
    }
}

// Usage
var saga = new SagaExecutor();
await saga.ExecuteAsync(new List<ISagaStep>
{
    new ReserveInventoryStep(_inventory),
    new ProcessPaymentStep(_payment),
    new CreateShipmentStep(_shipping)
}, context);
```

### Idempotent Compensations

```csharp
// Compensation must be idempotent (can be called multiple times)
public class RefundPaymentCompensation
{
    public async Task CompensateAsync(Guid orderId)
    {
        // Check if already refunded
        var refund = await _db.Refunds.FirstOrDefaultAsync(r => r.OrderId == orderId);
        if (refund != null)
        {
            // Already refunded - idempotent!
            return;
        }

        // Process refund
        var result = await _paymentGateway.RefundAsync(orderId);

        // Record refund
        await _db.Refunds.AddAsync(new Refund
        {
            OrderId = orderId,
            TransactionId = result.TransactionId,
            RefundedAt = DateTime.UtcNow
        });
        await _db.SaveChangesAsync();
    }
}
```

---

## 8. Eventual Consistency Patterns

> **What is Eventual Consistency?**
>
> **Eventual consistency** is a consistency model where, given enough time without new updates, all replicas of data will converge to the same value. It contrasts with strong consistency where all reads see the most recent write immediately.
>
> **Why use it?**
> - **Availability**: Systems can remain available even during network partitions (CAP theorem)
> - **Performance**: Writes don't need to wait for all replicas to acknowledge
> - **Scalability**: Easier to scale across regions and data centers
>
> **Trade-offs:**
> - Users may temporarily see stale data
> - Application logic must handle inconsistencies
> - More complex to reason about
>
> **Real-world examples:**
> - DNS: Updates propagate over minutes/hours, but system remains available
> - Social media feeds: Posts appear at different times for different users
> - Shopping cart: Inventory shown may be slightly stale
>
> **Related concept - CAP Theorem:**
> A distributed system can provide only 2 of 3 guarantees:
> - **Consistency**: All nodes see the same data at the same time
> - **Availability**: Every request gets a response
> - **Partition Tolerance**: System works despite network failures
>
> Since network partitions are unavoidable, you must choose between CP (consistent but may be unavailable) or AP (available but may be inconsistent).

### Read-Your-Writes Consistency

User should see their own changes immediately.

```csharp
public class OrderService
{
    private readonly IOrderRepository _writeRepo;
    private readonly IOrderReadModel _readModel; // Eventually consistent
    private readonly IDistributedCache _cache;

    public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
    {
        var order = new Order { Id = Guid.NewGuid(), Total = request.Total };

        // Write to primary database (immediate)
        await _writeRepo.SaveAsync(order);

        // Cache for immediate read-your-writes
        await _cache.SetAsync($"order:{order.Id}", order, TimeSpan.FromMinutes(5));

        // Publish event to update read model (eventual)
        await _bus.PublishAsync(new OrderCreatedEvent { OrderId = order.Id });

        return order;
    }

    public async Task<Order> GetOrderAsync(Guid orderId)
    {
        // Check cache first (read-your-writes)
        var cached = await _cache.GetAsync<Order>($"order:{orderId}");
        if (cached != null)
            return cached;

        // Fall back to read model (might be stale)
        return await _readModel.GetOrderAsync(orderId);
    }
}
```

### Monotonic Reads

User shouldn't see data go "backwards" in time.

```csharp
// Problem: User reads from different replicas
var order1 = await _replicaA.GetOrderAsync(orderId); // Status = Paid
var order2 = await _replicaB.GetOrderAsync(orderId); // Status = Pending (stale!)

// Solution: Session-based routing
public class MonotonicReadService
{
    public async Task<Order> GetOrderAsync(Guid orderId, string sessionId)
    {
        // Always route same session to same replica
        var replicaIndex = Math.Abs(sessionId.GetHashCode()) % _replicas.Count;
        var replica = _replicas[replicaIndex];

        return await replica.GetOrderAsync(orderId);
    }
}

// Or use versioned reads
public class VersionedReadService
{
    public async Task<Order> GetOrderAsync(Guid orderId, long? minVersion = null)
    {
        Order order;
        do
        {
            order = await _readModel.GetOrderAsync(orderId);

            if (minVersion.HasValue && order.Version < minVersion.Value)
            {
                // Wait for read model to catch up
                await Task.Delay(100);
            }
            else
            {
                break;
            }
        } while (true);

        return order;
    }
}
```

### Bounded Staleness

Guarantee data is not older than X seconds/minutes.

```csharp
public class BoundedStalenessRepository
{
    public async Task<Order> GetOrderAsync(Guid orderId, TimeSpan maxStaleness)
    {
        var order = await _readModel.GetOrderAsync(orderId);

        var staleness = DateTime.UtcNow - order.LastUpdated;
        if (staleness > maxStaleness)
        {
            // Too stale - read from primary
            return await _writeRepo.GetOrderAsync(orderId);
        }

        return order;
    }
}
```

---

## 9. Event-Driven System with Failure Scenarios

### Complete Example: E-Commerce Order Flow

```csharp
// 1. Order Service - Initiates saga
public class OrderService
{
    public async Task<OrderResult> CreateOrderAsync(CreateOrderRequest request)
    {
        var order = new Order
        {
            Id = Guid.NewGuid(),
            CustomerId = request.CustomerId,
            Items = request.Items,
            Status = OrderStatus.Created
        };

        // Save order
        await _repository.SaveAsync(order);

        // Publish event with correlation ID for tracking
        await _bus.PublishAsync(new OrderCreatedEvent
        {
            CorrelationId = Guid.NewGuid(),
            OrderId = order.Id,
            CustomerId = request.CustomerId,
            Items = request.Items,
            Total = request.Items.Sum(i => i.Price * i.Quantity)
        });

        return OrderResult.Success(order.Id);
    }
}

// 2. Inventory Service - Reserves stock
public class OrderCreatedHandler : IEventHandler<OrderCreatedEvent>
{
    public async Task HandleAsync(OrderCreatedEvent @event)
    {
        try
        {
            // Check stock availability
            foreach (var item in @event.Items)
            {
                var available = await _inventory.CheckStockAsync(item.ProductId, item.Quantity);
                if (!available)
                {
                    throw new InsufficientStockException($"Product {item.ProductId} out of stock");
                }
            }

            // Reserve stock
            await _inventory.ReserveAsync(@event.OrderId, @event.Items);

            // Success - publish event
            await _bus.PublishAsync(new InventoryReservedEvent
            {
                CorrelationId = @event.CorrelationId,
                OrderId = @event.OrderId,
                ReservedAt = DateTime.UtcNow
            });
        }
        catch (InsufficientStockException ex)
        {
            // Failure - publish failure event
            await _bus.PublishAsync(new InventoryReservationFailedEvent
            {
                CorrelationId = @event.CorrelationId,
                OrderId = @event.OrderId,
                Reason = ex.Message,
                FailedAt = DateTime.UtcNow
            });
        }
    }
}

// 3. Payment Service - Processes payment
public class InventoryReservedHandler : IEventHandler<InventoryReservedEvent>
{
    public async Task HandleAsync(InventoryReservedEvent @event)
    {
        try
        {
            var order = await _orderService.GetOrderAsync(@event.OrderId);

            // Call payment gateway with retry
            var result = await _retryPolicy.ExecuteAsync(async () =>
            {
                return await _paymentGateway.ChargeAsync(new ChargeRequest
                {
                    OrderId = @event.OrderId,
                    Amount = order.Total,
                    IdempotencyKey = @event.CorrelationId.ToString()
                });
            });

            if (result.IsSuccessful)
            {
                await _bus.PublishAsync(new PaymentSucceededEvent
                {
                    CorrelationId = @event.CorrelationId,
                    OrderId = @event.OrderId,
                    TransactionId = result.TransactionId,
                    ProcessedAt = DateTime.UtcNow
                });
            }
            else
            {
                await _bus.PublishAsync(new PaymentFailedEvent
                {
                    CorrelationId = @event.CorrelationId,
                    OrderId = @event.OrderId,
                    Reason = result.ErrorMessage,
                    FailedAt = DateTime.UtcNow
                });
            }
        }
        catch (Exception ex)
        {
            // Unexpected error
            await _bus.PublishAsync(new PaymentFailedEvent
            {
                CorrelationId = @event.CorrelationId,
                OrderId = @event.OrderId,
                Reason = ex.Message,
                FailedAt = DateTime.UtcNow
            });
        }
    }
}

// 4. Compensation Handlers
public class PaymentFailedHandler : IEventHandler<PaymentFailedEvent>
{
    public async Task HandleAsync(PaymentFailedEvent @event)
    {
        // Compensate - release inventory
        await _inventory.ReleaseReservationAsync(@event.OrderId);

        // Update order status
        var order = await _orderRepository.GetAsync(@event.OrderId);
        order.Status = OrderStatus.PaymentFailed;
        order.FailureReason = @event.Reason;
        await _orderRepository.SaveAsync(order);

        // Notify customer
        await _bus.PublishAsync(new OrderFailedEvent
        {
            CorrelationId = @event.CorrelationId,
            OrderId = @event.OrderId,
            Reason = @event.Reason
        });
    }
}

public class InventoryReservationFailedHandler : IEventHandler<InventoryReservationFailedEvent>
{
    public async Task HandleAsync(InventoryReservationFailedEvent @event)
    {
        // Update order status
        var order = await _orderRepository.GetAsync(@event.OrderId);
        order.Status = OrderStatus.OutOfStock;
        order.FailureReason = @event.Reason;
        await _orderRepository.SaveAsync(order);

        // Notify customer
        await _bus.PublishAsync(new OrderFailedEvent
        {
            CorrelationId = @event.CorrelationId,
            OrderId = @event.OrderId,
            Reason = @event.Reason
        });
    }
}

// 5. Success Path
public class PaymentSucceededHandler : IEventHandler<PaymentSucceededEvent>
{
    public async Task HandleAsync(PaymentSucceededEvent @event)
    {
        // Update order status
        var order = await _orderRepository.GetAsync(@event.OrderId);
        order.Status = OrderStatus.Paid;
        order.TransactionId = @event.TransactionId;
        await _orderRepository.SaveAsync(order);

        // Trigger next step (shipping)
        await _bus.PublishAsync(new OrderPaidEvent
        {
            CorrelationId = @event.CorrelationId,
            OrderId = @event.OrderId,
            PaidAt = DateTime.UtcNow
        });
    }
}

// 6. Monitoring - Track saga progress
public class SagaMonitor : IEventHandler<OrderCreatedEvent>,
    IEventHandler<InventoryReservedEvent>,
    IEventHandler<PaymentSucceededEvent>,
    IEventHandler<PaymentFailedEvent>
{
    public async Task HandleAsync(OrderCreatedEvent @event)
    {
        await _sagaStateRepo.CreateAsync(new SagaState
        {
            CorrelationId = @event.CorrelationId,
            OrderId = @event.OrderId,
            Status = "OrderCreated",
            UpdatedAt = DateTime.UtcNow
        });
    }

    public async Task HandleAsync(InventoryReservedEvent @event)
    {
        await _sagaStateRepo.UpdateAsync(@event.CorrelationId, "InventoryReserved");
    }

    public async Task HandleAsync(PaymentSucceededEvent @event)
    {
        await _sagaStateRepo.UpdateAsync(@event.CorrelationId, "Completed");
    }

    public async Task HandleAsync(PaymentFailedEvent @event)
    {
        await _sagaStateRepo.UpdateAsync(@event.CorrelationId, "Failed", @event.Reason);
    }
}
```

### Failure Scenarios Handled

1. **Inventory unavailable**: Publish failure event, update order status
2. **Payment fails**: Release inventory (compensation), update order status
3. **Payment gateway timeout**: Retry with idempotency key
4. **Duplicate messages**: Idempotent handlers prevent double-processing
5. **Partial failure**: Each step publishes success/failure event independently
6. **Network partition**: At-least-once delivery ensures messages eventually arrive

---

## 10. Interview Questions

### Q1: "How do you ensure message ordering in a distributed system?"

**Good Answer**:
"Message ordering is hard. You have three main approaches:

1. **Partition Key**: Send all related messages to the same partition (e.g., all orders for a customer). Same partition = guaranteed order.

2. **Sequence Numbers**: Add incrementing sequence number to messages. Consumer checks sequence and reorders or waits for missing messages.

3. **Design for Idempotency**: Make operations idempotent so order doesn't matter. Instead of `quantity += 1`, use `quantity = newValue`.

My preference is #3 - design for idempotency. It's more resilient and simpler. If ordering is absolutely critical, use partition keys, but understand you're limiting parallelism."

### Q2: "How do you handle duplicate messages?"

**Good Answer**:
"Duplicates are inevitable with at-least-once delivery. Three strategies:

1. **Idempotency Keys**: Store processed event IDs in cache/database. Check before processing.

2. **Natural Idempotency**: Design operations to be idempotent by nature (e.g., `status = Shipped` instead of `shippedCount++`).

3. **Database Unique Constraints**: Use unique index on event ID. Duplicate inserts fail, indicating already processed.

I use all three depending on context:
- Critical financial operations: Database unique constraint (durable)
- High-throughput operations: Cache-based idempotency keys (fast)
- Simple state changes: Natural idempotency (no infrastructure needed)"

### Q3: "Orchestration or choreography for sagas?"

**Good Answer**:
"It depends on complexity and coupling tolerance:

**Orchestration** (central coordinator):
- **When**: Complex workflow, need visibility, business process owner
- **Pros**: Easy to understand, centralized monitoring, explicit error handling
- **Cons**: Single point of coordination, tight coupling

**Choreography** (events):
- **When**: Loose coupling preferred, independent teams, simple workflow
- **Pros**: Decoupled, resilient, scales independently
- **Cons**: Hard to see full picture, need distributed tracing

For critical business processes (order fulfillment), I prefer orchestration. For supporting processes (notifications, analytics), choreography.

Reality: Often hybrid - orchestrate critical path, choreograph side effects."

### Q4: "How do you monitor distributed transactions?"

**Good Answer**:
"Distributed tracing and correlation IDs are essential:

1. **Correlation ID**: Generate unique ID for each saga, pass through all events/messages
2. **Distributed Tracing**: Use OpenTelemetry/Application Insights to trace across services
3. **Saga State Table**: Store saga progress in database (current step, started/completed times)
4. **Event Sourcing**: Store all events for full audit trail

Example:
```csharp
// Generate correlation ID
var correlationId = Guid.NewGuid();

// Pass through all events
await _bus.PublishAsync(new OrderCreatedEvent
{
    CorrelationId = correlationId,
    OrderId = order.Id
});

// Track in saga state table
await _sagaState.CreateAsync(new SagaState
{
    CorrelationId = correlationId,
    Status = "Started",
    CurrentStep = "OrderCreated"
});
```

With correlation ID, I can query all events/logs for a single transaction across all services."

---

## Summary

**Key Principles**:

1. **At-least-once delivery + Idempotency = Exactly-once processing**
2. **Ordering is hard** - Use partition keys or design for idempotency
3. **Duplicates will happen** - Handle them via idempotency keys or natural idempotency
4. **Sagas for distributed transactions** - Orchestration (central) or choreography (events)
5. **Compensations, not rollbacks** - Undo via compensating transactions
6. **Eventual consistency is okay** - Most use cases don't need immediate consistency
7. **Dead letter queues** - Handle poison messages gracefully
8. **Correlation IDs** - Essential for tracing distributed workflows
9. **Outbox pattern** - Ensure events are published when transaction commits
10. **Monitor saga state** - Know where each transaction is in the workflow

**Remember**: Distributed systems are inherently complex. Embrace eventual consistency, design for failure, and make everything idempotent.

