# Day 17: Kafka & Event Streaming Deep Dive

## Overview
Apache Kafka is a distributed event streaming platform used by 80% of Fortune 100 companies. This guide covers Kafka architecture, partitioning strategies, consumer groups, and integration with .NET/Azure for Senior/SDE-2 interviews at top companies (Uber, Netflix, LinkedIn, Microsoft).

**Real Interview Context:**
- Amazon: "Design a real-time order tracking system using Kafka"
- Uber: "How would you handle exactly-once processing in a payment service?"
- Netflix: "Explain consumer lag and how to detect/fix it"
- Microsoft: "Integrate Kafka with Azure Event Hubs for hybrid scenarios"

---

## 1. Kafka Architecture Fundamentals

> **Key Terminology Explained:**
>
> **Backpressure**: A mechanism where a slower consumer signals to producers to slow down message production. When consumers can't keep up with the incoming message rate, backpressure prevents the system from being overwhelmed by either:
> - Slowing down producers (rate limiting)
> - Buffering messages (with bounded queues)
> - Dropping messages (with proper handling)
>
> **Consumer Lag**: The difference between the latest message offset produced and the latest message offset consumed. High lag indicates consumers are falling behind.
> ```
> Producer offset: 1000 (latest message)
> Consumer offset: 800 (last consumed)
> Consumer lag: 200 messages behind
> ```
>
> **Offset**: A unique, sequential identifier for each message within a partition. Consumers track their progress by storing the last processed offset.
>
> **Partition**: A division of a Kafka topic that allows parallel processing. Messages in the same partition maintain strict ordering.
>
> **Replication Factor**: The number of copies of each partition stored across different brokers for fault tolerance.
>
> **ISR (In-Sync Replicas)**: The set of replicas that are fully caught up with the leader. Only ISR members can become the new leader if the current leader fails.

### Core Concepts

```
┌─────────────────────────────────────────────────────────────┐
│                     KAFKA CLUSTER                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────┐         ┌─────────┐         ┌─────────┐     │
│   │ Broker 1│         │ Broker 2│         │ Broker 3│     │
│   │ (Leader)│         │(Replica)│         │(Replica)│     │
│   └────┬────┘         └────┬────┘         └────┬────┘     │
│        │                   │                   │           │
│   ┌────▼────────────────────▼───────────────────▼────┐     │
│   │  Topic: orders                                   │     │
│   │  ┌─────────┐  ┌─────────┐  ┌─────────┐          │     │
│   │  │Partition│  │Partition│  │Partition│          │     │
│   │  │   0     │  │   1     │  │   2     │          │     │
│   │  │Leader:B1│  │Leader:B2│  │Leader:B3│          │     │
│   │  └─────────┘  └─────────┘  └─────────┘          │     │
│   └──────────────────────────────────────────────────┘     │
│                                                             │
│   ┌─────────────────────────────────────────────────┐      │
│   │ ZooKeeper (or KRaft in Kafka 3.x)               │      │
│   │ - Leader election                                │      │
│   │ - Cluster metadata                               │      │
│   │ - Consumer group coordination                    │      │
│   └─────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘

       ▲                                        │
       │                                        │
   Producers                               Consumers
```

**Tech Lead Decision Framework:**
- **Partitions**: More partitions = higher throughput, but increased overhead
- **Replication Factor**: 3 is standard (tolerates 2 broker failures)
- **ISR (In-Sync Replicas)**: Critical for durability guarantees

### .NET Producer Implementation

```csharp
// Confluent.Kafka NuGet package
using Confluent.Kafka;

public class KafkaProducerService : IDisposable
{
    private readonly IProducer<string, string> _producer;
    private readonly ILogger<KafkaProducerService> _logger;

    public KafkaProducerService(IConfiguration config, ILogger<KafkaProducerService> logger)
    {
        _logger = logger;

        var producerConfig = new ProducerConfig
        {
            BootstrapServers = config["Kafka:BootstrapServers"], // "localhost:9092"

            // Durability vs Performance trade-off
            Acks = Acks.All, // Wait for all in-sync replicas (safest, slowest)
            // Acks.Leader = only leader acknowledges (faster, less safe)
            // Acks.None = fire and forget (fastest, unsafe)

            // Idempotence - prevents duplicate messages
            EnableIdempotence = true, // Exactly-once semantics within partition

            // Compression - reduces network/storage, adds CPU cost
            CompressionType = CompressionType.Snappy, // Good balance
            // Alternatives: Gzip (better compression), Lz4 (faster), None

            // Batching for throughput
            LingerMs = 10, // Wait up to 10ms to batch messages
            BatchSize = 16384, // 16KB batch size

            // Retries
            MessageSendMaxRetries = 3,
            RetryBackoffMs = 100,

            // Timeouts
            RequestTimeoutMs = 30000, // 30 seconds
        };

        _producer = new ProducerBuilder<string, string>(producerConfig)
            .SetErrorHandler((producer, error) =>
            {
                _logger.LogError($"Kafka error: {error.Reason}");
            })
            .Build();
    }

    // Fire-and-forget (fastest, least reliable)
    public void SendFireAndForget(string topic, string key, string value)
    {
        _producer.Produce(topic, new Message<string, string>
        {
            Key = key,
            Value = value
        });
    }

    // Synchronous send (blocking, slowest, most reliable)
    public async Task<DeliveryResult<string, string>> SendSyncAsync(
        string topic, string key, string value)
    {
        try
        {
            var result = await _producer.ProduceAsync(topic, new Message<string, string>
            {
                Key = key,
                Value = value,
                Timestamp = Timestamp.Default // Use broker time
            });

            _logger.LogInformation(
                $"Message delivered to {result.TopicPartitionOffset}");

            return result;
        }
        catch (ProduceException<string, string> ex)
        {
            _logger.LogError($"Failed to deliver message: {ex.Error.Reason}");
            throw;
        }
    }

    // Async with callback (best balance)
    public void SendAsync(string topic, string key, string value,
        Action<DeliveryReport<string, string>> callback)
    {
        _producer.Produce(topic, new Message<string, string>
        {
            Key = key,
            Value = value
        }, callback);
    }

    // Transactional producer (exactly-once semantics across topics)
    public async Task SendTransactionalAsync(
        List<(string topic, string key, string value)> messages)
    {
        _producer.InitTransactions(TimeSpan.FromSeconds(30));
        _producer.BeginTransaction();

        try
        {
            foreach (var (topic, key, value) in messages)
            {
                await _producer.ProduceAsync(topic, new Message<string, string>
                {
                    Key = key,
                    Value = value
                });
            }

            _producer.CommitTransaction();
        }
        catch (Exception ex)
        {
            _logger.LogError($"Transaction failed: {ex.Message}");
            _producer.AbortTransaction();
            throw;
        }
    }

    public void Dispose()
    {
        _producer?.Flush(TimeSpan.FromSeconds(10)); // Wait for pending messages
        _producer?.Dispose();
    }
}

// Usage in ASP.NET Core
public class OrderController : ControllerBase
{
    private readonly KafkaProducerService _kafka;

    [HttpPost("orders")]
    public async Task<IActionResult> CreateOrder(CreateOrderDto dto)
    {
        var order = await _orderService.CreateOrderAsync(dto);

        // Publish event to Kafka
        var orderEvent = JsonSerializer.Serialize(new
        {
            order.Id,
            order.CustomerId,
            order.Total,
            Timestamp = DateTime.UtcNow
        });

        await _kafka.SendSyncAsync("orders", order.Id.ToString(), orderEvent);

        return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
    }
}
```

**Interview Talking Points:**
- "Acks=All ensures message is written to all in-sync replicas before acknowledging"
- "EnableIdempotence prevents duplicate messages from retries (exactly-once within partition)"
- "Batching (LingerMs, BatchSize) trades latency for throughput"
- "Synchronous send blocks thread - use async for high throughput scenarios"

---

## 2. Consumer Groups & Partition Assignment

### Consumer Group Architecture

```
Topic: orders (6 partitions)
┌──────────────────────────────────────────────────────────┐
│ P0 │ P1 │ P2 │ P3 │ P4 │ P5 │                           │
└──┬───┴──┬───┴──┬───┴──┬───┴──┬───┴──┬───────────────────┘
   │      │      │      │      │      │
   └──────┼──────┘      └──────┼──────┘
          │                    │
   ┌──────▼─────┐       ┌──────▼─────┐
   │Consumer 1  │       │Consumer 2  │
   │(P0, P1, P2)│       │(P3, P4, P5)│
   └────────────┘       └────────────┘

   Consumer Group: order-processing

   Scaling: Add Consumer 3 → Rebalance → Each gets 2 partitions
```

**Critical Concepts:**
- **One partition → One consumer** within a group (exclusive ownership)
- **More consumers than partitions** → Some consumers idle
- **Consumer dies** → Partitions reassigned to remaining consumers
- **Rebalancing** → All consumers temporarily stop processing (costly)

### .NET Consumer Implementation

```csharp
public class KafkaConsumerService : BackgroundService
{
    private readonly IConsumer<string, string> _consumer;
    private readonly ILogger<KafkaConsumerService> _logger;
    private readonly IServiceScopeFactory _scopeFactory;

    public KafkaConsumerService(
        IConfiguration config,
        ILogger<KafkaConsumerService> logger,
        IServiceScopeFactory scopeFactory)
    {
        _logger = logger;
        _scopeFactory = scopeFactory;

        var consumerConfig = new ConsumerConfig
        {
            BootstrapServers = config["Kafka:BootstrapServers"],

            // Consumer Group ID - CRITICAL for scaling
            GroupId = "order-processing-service",

            // Offset management
            AutoOffsetReset = AutoOffsetReset.Earliest,
            // Earliest = process from beginning if no committed offset
            // Latest = only process new messages

            // Manual offset commit (recommended for exactly-once)
            EnableAutoCommit = false,

            // Heartbeat and session management
            SessionTimeoutMs = 45000, // 45s - broker removes consumer if no heartbeat
            HeartbeatIntervalMs = 3000, // 3s - send heartbeat to coordinator
            MaxPollIntervalMs = 300000, // 5 min - max time between poll() calls

            // Partition assignment strategy
            PartitionAssignmentStrategy = PartitionAssignmentStrategy.CooperativeSticky,
            // CooperativeSticky = minimize rebalancing disruption
            // RoundRobin = even distribution (more rebalancing)

            // Performance tuning
            FetchMinBytes = 1024, // Wait for 1KB before returning fetch
            FetchWaitMaxMs = 500, // Or wait max 500ms
            MaxPartitionFetchBytes = 1048576, // 1MB per partition per fetch
        };

        _consumer = new ConsumerBuilder<string, string>(consumerConfig)
            .SetErrorHandler((consumer, error) =>
            {
                _logger.LogError($"Consumer error: {error.Reason}");
            })
            .SetPartitionsAssignedHandler((consumer, partitions) =>
            {
                _logger.LogInformation($"Partitions assigned: {string.Join(", ", partitions)}");
            })
            .SetPartitionsRevokedHandler((consumer, partitions) =>
            {
                _logger.LogWarning($"Partitions revoked: {string.Join(", ", partitions)}");
                // Commit offsets before rebalance
                consumer.Commit();
            })
            .Build();
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _consumer.Subscribe("orders");

        try
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    var consumeResult = _consumer.Consume(stoppingToken);

                    if (consumeResult?.Message != null)
                    {
                        await ProcessMessageAsync(consumeResult.Message, stoppingToken);

                        // Manual offset commit (exactly-once semantics)
                        _consumer.Commit(consumeResult);

                        _logger.LogInformation(
                            $"Processed offset {consumeResult.Offset} " +
                            $"from partition {consumeResult.Partition}");
                    }
                }
                catch (ConsumeException ex)
                {
                    _logger.LogError($"Consume error: {ex.Error.Reason}");
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Processing error: {ex.Message}");
                    // Don't commit offset on error - message will be reprocessed
                }
            }
        }
        finally
        {
            _consumer.Close();
        }
    }

    private async Task ProcessMessageAsync(Message<string, string> message,
        CancellationToken cancellationToken)
    {
        // Use scoped service for processing (DbContext, etc.)
        using var scope = _scopeFactory.CreateScope();
        var orderService = scope.ServiceProvider.GetRequiredService<IOrderService>();

        var orderEvent = JsonSerializer.Deserialize<OrderEvent>(message.Value);

        await orderService.ProcessOrderEventAsync(orderEvent, cancellationToken);
    }

    public override void Dispose()
    {
        _consumer?.Dispose();
        base.Dispose();
    }
}

// Advanced: Parallel processing within partitions (use with caution)
public class ParallelKafkaConsumer : BackgroundService
{
    private readonly IConsumer<string, string> _consumer;
    private readonly SemaphoreSlim _semaphore = new(10, 10); // Max 10 concurrent

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _consumer.Subscribe("orders");

        while (!stoppingToken.IsCancellationRequested)
        {
            var consumeResult = _consumer.Consume(stoppingToken);

            if (consumeResult?.Message != null)
            {
                await _semaphore.WaitAsync(stoppingToken);

                // Process in background, but DON'T commit offset yet
                _ = Task.Run(async () =>
                {
                    try
                    {
                        await ProcessMessageAsync(consumeResult.Message, stoppingToken);

                        // Problem: Can't guarantee offset order!
                        // Solution: Track offsets and commit in order
                    }
                    finally
                    {
                        _semaphore.Release();
                    }
                }, stoppingToken);
            }
        }
    }
}
```

**Interview Talking Points:**
- "EnableAutoCommit=false prevents data loss if consumer crashes before processing"
- "SessionTimeoutMs must be > processing time, or consumer is kicked from group"
- "CooperativeSticky minimizes rebalancing - only affected partitions move"
- "Parallel processing within consumer breaks offset ordering guarantees"

---

## 3. Partitioning Strategies

### Key-Based Partitioning

```csharp
// Default: Hash(key) % partition_count
// Messages with same key → same partition → ordered processing

// Example: Order events by customer
public async Task PublishOrderEventAsync(OrderEvent orderEvent)
{
    // Use customerId as key - all orders for same customer go to same partition
    var key = orderEvent.CustomerId.ToString();
    var value = JsonSerializer.Serialize(orderEvent);

    await _producer.ProduceAsync("orders", new Message<string, string>
    {
        Key = key, // Determines partition
        Value = value
    });
}

// Consumer processes all orders for a customer in order
// Multiple customers are processed in parallel (different partitions)
```

**Custom Partitioner:**

```csharp
public class CustomPartitioner : IPartitioner
{
    public int Partition(
        string topic,
        int partitionCount,
        ReadOnlySpan<byte> keyData,
        bool keyIsNull)
    {
        if (keyIsNull)
            return Random.Shared.Next(partitionCount);

        // Custom logic: Route high-value customers to specific partitions
        var customerId = Encoding.UTF8.GetString(keyData);

        if (IsHighValueCustomer(customerId))
        {
            // Dedicate partition 0 for high-value customers
            return 0;
        }

        // Hash-based for others
        return Math.Abs(customerId.GetHashCode()) % (partitionCount - 1) + 1;
    }

    private bool IsHighValueCustomer(string customerId)
    {
        // Check against high-value customer list
        return false;
    }
}

// Register partitioner
var producerConfig = new ProducerConfig
{
    BootstrapServers = "localhost:9092",
    Partitioner = Partitioner.Murmur2 // or custom
};
```

**Partition Count Decision Matrix:**

| Scenario | Partition Count | Reasoning |
|----------|-----------------|-----------|
| **Low throughput (< 1K msg/sec)** | 3-6 | Overhead not worth it |
| **High throughput (> 10K msg/sec)** | 30-50 | Maximize parallelism |
| **Ordered processing required** | Fewer (6-12) | Easier to maintain order |
| **Hot key problem** | More partitions | Spread load, but won't fix hot key |
| **Consumer count** | Partitions ≥ Consumers | Avoid idle consumers |

**Interview Question: "How do you handle hot keys?"**

```csharp
// Problem: One customer creates 90% of orders → One partition overloaded

// Solution 1: Add sub-key for distribution
public string GenerateKey(Guid customerId, int orderCount)
{
    // Distribute orders from same customer across multiple partitions
    var subKey = orderCount % 10; // 10 sub-partitions per customer
    return $"{customerId}:{subKey}";

    // Trade-off: Lose strict ordering for that customer
}

// Solution 2: Increase partition count (doesn't fully solve)
// Solution 3: Use custom partitioner to route hot keys to dedicated partitions
// Solution 4: Pre-aggregate hot key data before publishing
```

---

## 4. Exactly-Once Semantics (EOS)

### Delivery Guarantees

```
┌─────────────────────────────────────────────────────────────┐
│ Delivery Guarantee     │ Producer Config │ Consumer Behavior│
├─────────────────────────────────────────────────────────────┤
│ At-Most-Once           │ Acks = 0        │ Auto-commit      │
│ (Messages can be lost) │ Retries = 0     │ EnableAutoCommit │
├─────────────────────────────────────────────────────────────┤
│ At-Least-Once          │ Acks = All      │ Manual commit    │
│ (Duplicates possible)  │ Retries > 0     │ After processing │
├─────────────────────────────────────────────────────────────┤
│ Exactly-Once           │ Idempotent=true │ Transactional    │
│ (No loss, no dupes)    │ Transactional   │ read + write     │
└─────────────────────────────────────────────────────────────┘
```

### Exactly-Once Implementation

```csharp
// Idempotent Consumer Pattern (Application-Level EOS)
public class IdempotentOrderProcessor
{
    private readonly IDistributedCache _cache;
    private readonly IOrderRepository _repository;

    public async Task ProcessOrderEventAsync(OrderEvent orderEvent)
    {
        // Idempotency key: combination of event ID + offset
        var idempotencyKey = $"order-event:{orderEvent.Id}";

        // Check if already processed
        var processed = await _cache.GetStringAsync(idempotencyKey);
        if (processed != null)
        {
            // Already processed - skip
            return;
        }

        // Process order
        await _repository.CreateOrderAsync(orderEvent.ToOrder());

        // Mark as processed (TTL = 7 days)
        await _cache.SetStringAsync(
            idempotencyKey,
            "processed",
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromDays(7)
            });
    }
}

// Kafka Transactions (Producer-Level EOS)
public class TransactionalKafkaService
{
    private readonly IProducer<string, string> _producer;

    public TransactionalKafkaService()
    {
        var config = new ProducerConfig
        {
            BootstrapServers = "localhost:9092",
            TransactionalId = "order-service-tx-1", // Unique per producer instance
            EnableIdempotence = true,
            Acks = Acks.All
        };

        _producer = new ProducerBuilder<string, string>(config).Build();
        _producer.InitTransactions(TimeSpan.FromSeconds(30));
    }

    public async Task ProcessOrderWithExactlyOnceAsync(
        ConsumeResult<string, string> consumeResult,
        Order processedOrder)
    {
        _producer.BeginTransaction();

        try
        {
            // 1. Produce output event
            await _producer.ProduceAsync("order-processed", new Message<string, string>
            {
                Key = processedOrder.Id.ToString(),
                Value = JsonSerializer.Serialize(processedOrder)
            });

            // 2. Commit consumed offset (atomic with produce)
            var consumerGroupMetadata = _consumer.ConsumerGroupMetadata;
            var offsetsToCommit = new[]
            {
                new TopicPartitionOffset(
                    consumeResult.TopicPartition,
                    consumeResult.Offset + 1)
            };

            _producer.SendOffsetsToTransaction(
                offsetsToCommit,
                consumerGroupMetadata,
                TimeSpan.FromSeconds(10));

            // Commit transaction - either both succeed or both fail
            _producer.CommitTransaction();
        }
        catch (Exception ex)
        {
            _producer.AbortTransaction();
            throw;
        }
    }
}

// Consumer reading transactional messages
var consumerConfig = new ConsumerConfig
{
    // Only read committed messages (ignore uncommitted)
    IsolationLevel = IsolationLevel.ReadCommitted
};
```

**Interview Talking Points:**
- "True exactly-once requires transactions + idempotent producer + read_committed consumer"
- "Application-level idempotency is simpler but requires external store (Redis, DB)"
- "Kafka transactions are expensive - use only when needed (payment processing, financial data)"
- "Most systems use at-least-once + idempotent consumers (good balance)"

---

## 5. Consumer Lag & Monitoring

### Detecting Consumer Lag

```csharp
public class KafkaMonitoringService : BackgroundService
{
    private readonly IAdminClient _adminClient;
    private readonly ILogger<KafkaMonitoringService> _logger;
    private readonly IMetricsCollector _metrics;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            await MonitorConsumerLagAsync();
            await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
        }
    }

    private async Task MonitorConsumerLagAsync()
    {
        try
        {
            var groupId = "order-processing-service";

            // Get consumer group info
            var groupInfo = _adminClient.ListGroup(groupId, TimeSpan.FromSeconds(10));

            // Get committed offsets
            var committedOffsets = _adminClient.ListConsumerGroupOffsets(
                groupId,
                null,
                TimeSpan.FromSeconds(10));

            // Get watermarks (high/low offsets per partition)
            foreach (var partition in committedOffsets.Partitions)
            {
                var watermark = _adminClient.QueryWatermarkOffsets(
                    partition.TopicPartition,
                    TimeSpan.FromSeconds(10));

                var committedOffset = partition.Offset.Value;
                var highWatermark = watermark.High.Value;
                var lag = highWatermark - committedOffset;

                _logger.LogInformation(
                    $"Topic: {partition.Topic}, " +
                    $"Partition: {partition.Partition}, " +
                    $"Lag: {lag} messages");

                // Send metric to monitoring system
                _metrics.Gauge($"kafka.consumer.lag", lag, new Dictionary<string, string>
                {
                    ["topic"] = partition.Topic,
                    ["partition"] = partition.Partition.ToString(),
                    ["consumer_group"] = groupId
                });

                // Alert if lag exceeds threshold
                if (lag > 10000)
                {
                    _logger.LogWarning(
                        $"High consumer lag detected: {lag} messages on " +
                        $"{partition.Topic}:{partition.Partition}");
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError($"Failed to monitor consumer lag: {ex.Message}");
        }
    }
}

// Application Insights integration
public class ApplicationInsightsKafkaMetrics
{
    private readonly TelemetryClient _telemetry;

    public void TrackConsumerLag(string topic, int partition, long lag)
    {
        _telemetry.TrackMetric(
            "KafkaConsumerLag",
            lag,
            new Dictionary<string, string>
            {
                ["Topic"] = topic,
                ["Partition"] = partition.ToString()
            });
    }

    public void TrackMessageProcessingTime(TimeSpan duration)
    {
        _telemetry.TrackMetric("KafkaMessageProcessingTime", duration.TotalMilliseconds);
    }

    public void TrackConsumerRebalance(int partitionCount)
    {
        _telemetry.TrackEvent("KafkaConsumerRebalance", new Dictionary<string, string>
        {
            ["PartitionCount"] = partitionCount.ToString(),
            ["Timestamp"] = DateTime.UtcNow.ToString("o")
        });
    }
}
```

**Fixing Consumer Lag:**

```
┌────────────────────────────────────────────────────────────┐
│ Cause of Lag              │ Solution                        │
├────────────────────────────────────────────────────────────┤
│ Slow message processing   │ Optimize processing logic       │
│                           │ Add more consumers (scale)      │
│                           │ Increase batch size             │
├────────────────────────────────────────────────────────────┤
│ Consumer crashes/restarts │ Fix bugs, handle exceptions     │
│                           │ Increase session timeout        │
│                           │ Checkpoint more frequently      │
├────────────────────────────────────────────────────────────┤
│ Sudden traffic spike      │ Auto-scaling consumers          │
│                           │ Rate limiting producers         │
│                           │ Backpressure mechanisms         │
├────────────────────────────────────────────────────────────┤
│ Rebalancing storms        │ Use CooperativeSticky strategy  │
│                           │ Increase session timeout        │
│                           │ Reduce consumer restarts        │
└────────────────────────────────────────────────────────────┘
```

---

## 6. Azure Event Hubs vs Kafka

### Comparison Matrix

| Feature | Apache Kafka | Azure Event Hubs |
|---------|--------------|------------------|
| **Protocol** | Native Kafka | Kafka-compatible + AMQP |
| **Management** | Self-hosted (complex) | Fully managed (simple) |
| **Pricing** | VM/compute costs | Pay per throughput unit |
| **Max throughput** | Unlimited (scale brokers) | 1-20 TU (20 MB/s per TU) |
| **Retention** | Configurable (days-years) | 1-7 days (90 days premium) |
| **Consumer groups** | Unlimited | 20 per namespace |
| **Partitions** | Configurable | 32 per Event Hub |
| **Schema Registry** | Confluent Schema Registry | Azure Schema Registry |
| **Best for** | High throughput, self-managed | Azure-native, managed service |

### Hybrid Architecture (Kafka + Event Hubs)

```csharp
// Scenario: On-prem Kafka → Azure Event Hubs → Azure services
public class KafkaToEventHubsBridge
{
    private readonly IConsumer<string, string> _kafkaConsumer;
    private readonly EventHubProducerClient _eventHubProducer;

    public KafkaToEventHubsBridge(string kafkaBootstrap, string eventHubConnectionString)
    {
        // On-prem Kafka consumer
        _kafkaConsumer = new ConsumerBuilder<string, string>(new ConsumerConfig
        {
            BootstrapServers = kafkaBootstrap,
            GroupId = "kafka-eventhub-bridge"
        }).Build();

        // Azure Event Hubs producer
        _eventHubProducer = new EventHubProducerClient(eventHubConnectionString);
    }

    public async Task BridgeMessagesAsync(CancellationToken cancellationToken)
    {
        _kafkaConsumer.Subscribe("orders");

        while (!cancellationToken.IsCancellationRequested)
        {
            var consumeResult = _kafkaConsumer.Consume(cancellationToken);

            // Transform message
            var eventData = new EventData(Encoding.UTF8.GetBytes(consumeResult.Message.Value))
            {
                PartitionKey = consumeResult.Message.Key,
                Properties =
                {
                    ["SourceTopic"] = consumeResult.Topic,
                    ["SourcePartition"] = consumeResult.Partition.Value.ToString(),
                    ["SourceOffset"] = consumeResult.Offset.Value.ToString()
                }
            };

            // Send to Event Hubs
            await _eventHubProducer.SendAsync(new[] { eventData }, cancellationToken);

            // Commit offset
            _kafkaConsumer.Commit(consumeResult);
        }
    }
}

// Use Event Hubs Kafka endpoint (no bridge needed)
var producerConfig = new ProducerConfig
{
    BootstrapServers = "my-namespace.servicebus.windows.net:9093",
    SecurityProtocol = SecurityProtocol.SaslSsl,
    SaslMechanism = SaslMechanism.Plain,
    SaslUsername = "$ConnectionString",
    SaslPassword = "<Event Hubs connection string>"
};

// Code remains same - Event Hubs speaks Kafka protocol!
```

---

## 7. Kafka Streams & KSQL (Advanced)

### Stream Processing in .NET

```csharp
// Real-time aggregation using Kafka Streams (via Streamiz library)
public class OrderAggregationStream
{
    public void BuildTopology()
    {
        var config = new StreamConfig<StringSerDes, StringSerDes>
        {
            ApplicationId = "order-aggregation",
            BootstrapServers = "localhost:9092"
        };

        var builder = new StreamBuilder();

        // Read orders stream
        var ordersStream = builder.Stream<string, string>("orders");

        // Parse JSON
        var parsedOrders = ordersStream
            .MapValues(json => JsonSerializer.Deserialize<Order>(json));

        // Group by customer ID and aggregate
        var aggregatedByCustomer = parsedOrders
            .GroupBy((key, order) => order.CustomerId.ToString())
            .Aggregate(
                () => new CustomerOrderSummary(),
                (key, order, summary) =>
                {
                    summary.TotalOrders++;
                    summary.TotalSpent += order.Total;
                    return summary;
                },
                Materialized<string, CustomerOrderSummary, IKeyValueStore<Bytes, byte[]>>.Create("customer-aggregates")
            );

        // Write results to output topic
        aggregatedByCustomer
            .ToStream()
            .MapValues(summary => JsonSerializer.Serialize(summary))
            .To("customer-order-summaries");

        var stream = new KafkaStream(builder.Build(), config);
        stream.Start();
    }
}

// Query materialized view (interactive queries)
public class CustomerSummaryQuery
{
    private readonly KafkaStream _stream;

    public CustomerOrderSummary GetCustomerSummary(string customerId)
    {
        var store = _stream.Store<IReadOnlyKeyValueStore<string, CustomerOrderSummary>>(
            "customer-aggregates");

        return store.Get(customerId);
    }
}
```

---

## 8. Real Interview Scenarios

### Amazon: Design Real-Time Order Tracking

**Question:** "Design a system where customers can see real-time updates of their order status (placed → confirmed → shipped → delivered)."

**Answer:**

```csharp
// Architecture:
// Order Service → Kafka (orders topic) → Notification Service
//                                      ↘ Tracking Service → SignalR → React

// 1. Order Service publishes events
public class OrderService
{
    private readonly KafkaProducerService _kafka;

    public async Task UpdateOrderStatusAsync(Guid orderId, OrderStatus newStatus)
    {
        var order = await _repository.GetByIdAsync(orderId);
        order.UpdateStatus(newStatus);
        await _repository.SaveAsync(order);

        // Publish event to Kafka
        var orderEvent = new OrderStatusChangedEvent
        {
            OrderId = orderId,
            CustomerId = order.CustomerId,
            OldStatus = order.PreviousStatus,
            NewStatus = newStatus,
            Timestamp = DateTime.UtcNow
        };

        await _kafka.SendSyncAsync(
            "order-status-changes",
            orderId.ToString(),
            JsonSerializer.Serialize(orderEvent));
    }
}

// 2. Tracking Service consumes events
public class OrderTrackingConsumer : BackgroundService
{
    private readonly IHubContext<OrderTrackingHub> _hubContext;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _consumer.Subscribe("order-status-changes");

        while (!stoppingToken.IsCancellationRequested)
        {
            var result = _consumer.Consume(stoppingToken);
            var orderEvent = JsonSerializer.Deserialize<OrderStatusChangedEvent>(
                result.Message.Value);

            // Push to connected customers via SignalR
            await _hubContext.Clients
                .User(orderEvent.CustomerId.ToString())
                .SendAsync("OrderStatusUpdate", orderEvent, stoppingToken);

            _consumer.Commit(result);
        }
    }
}

// 3. React frontend receives real-time updates
const useOrderTracking = (orderId) => {
    const [status, setStatus] = useState(null);

    useEffect(() => {
        const connection = new HubConnectionBuilder()
            .withUrl('/hubs/order-tracking')
            .build();

        connection.on('OrderStatusUpdate', (event) => {
            if (event.orderId === orderId) {
                setStatus(event.newStatus);
            }
        });

        connection.start();

        return () => connection.stop();
    }, [orderId]);

    return status;
};
```

**Trade-offs Discussed:**
- Kafka for event persistence vs direct SignalR (reliability)
- Consumer group per service (isolation) vs shared group (cost)
- WebSocket vs SSE vs polling (browser compatibility, scalability)

### Uber: Exactly-Once Payment Processing

**Question:** "How do you ensure payment events are processed exactly once? What happens if the consumer crashes after deducting money but before committing offset?"

**Answer:**

```csharp
// Solution 1: Database + Kafka atomic commit (best)
public class PaymentProcessor
{
    private readonly IDbConnection _db;
    private readonly IConsumer<string, string> _consumer;

    public async Task ProcessPaymentEventAsync(ConsumeResult<string, string> result)
    {
        var paymentEvent = JsonSerializer.Deserialize<PaymentEvent>(result.Message.Value);

        // Start database transaction
        using var transaction = await _db.BeginTransactionAsync();

        try
        {
            // 1. Check idempotency (event_id unique constraint in DB)
            var alreadyProcessed = await _db.QueryFirstOrDefaultAsync<ProcessedEvent>(
                "SELECT * FROM processed_events WHERE event_id = @EventId",
                new { EventId = paymentEvent.EventId });

            if (alreadyProcessed != null)
            {
                // Already processed - just commit offset
                _consumer.Commit(result);
                return;
            }

            // 2. Process payment (deduct money, update balance, etc.)
            await _paymentService.ProcessPaymentAsync(paymentEvent);

            // 3. Store Kafka offset in same transaction
            await _db.ExecuteAsync(@"
                INSERT INTO kafka_offsets (topic, partition, offset, consumer_group)
                VALUES (@Topic, @Partition, @Offset, @Group)
                ON CONFLICT (topic, partition, consumer_group)
                DO UPDATE SET offset = @Offset",
                new
                {
                    Topic = result.Topic,
                    Partition = result.Partition.Value,
                    Offset = result.Offset.Value,
                    Group = "payment-processor"
                });

            // 4. Mark event as processed
            await _db.ExecuteAsync(@"
                INSERT INTO processed_events (event_id, processed_at)
                VALUES (@EventId, @ProcessedAt)",
                new
                {
                    EventId = paymentEvent.EventId,
                    ProcessedAt = DateTime.UtcNow
                });

            // Commit transaction (atomic: payment + offset)
            await transaction.CommitAsync();

            // Commit to Kafka (safe - already in DB)
            _consumer.Commit(result);
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync();
            throw; // Don't commit offset - will retry
        }
    }
}

// Solution 2: Kafka Transactions (if not using DB)
// (Already shown in section 4)
```

**Interview Talking Points:**
- "Store Kafka offset in same DB transaction as business operation"
- "Idempotency key (event_id) prevents duplicate processing"
- "If crash happens, offset not committed → message reprocessed → DB catches duplicate"
- "Alternative: Two-phase commit (complex, avoided in practice)"

---

## 9. Common Interview Questions & Answers

### Q1: "How do you handle message ordering in Kafka?"

**Answer:**
"Kafka guarantees ordering **within a partition**, not across partitions. To maintain order:

1. **Use consistent key**: Messages with same key go to same partition
2. **Single consumer per partition**: Consumer group ensures this
3. **Process sequentially**: Don't parallelize processing within partition

Example: Order events for customer123 all use `customer123` as key → same partition → processed in order.

Trade-off: Strict ordering limits parallelism. If you need high throughput, consider relaxing ordering requirements (eventual consistency)."

### Q2: "What causes consumer rebalancing and how do you minimize it?"

**Answer:**
"Rebalancing happens when:
- Consumer joins/leaves group
- Consumer heartbeat timeout (crashed/slow processing)
- Partition count changes
- Consumer manually unsubscribes

**Minimize rebalancing:**
```csharp
var config = new ConsumerConfig
{
    SessionTimeoutMs = 45000, // Higher = tolerates longer processing
    MaxPollIntervalMs = 300000, // Max time between poll() calls
    HeartbeatIntervalMs = 3000, // Frequent heartbeats
    PartitionAssignmentStrategy = PartitionAssignmentStrategy.CooperativeSticky
    // ^ Only affected partitions move, not all
};
```

**Impact:** During rebalancing, all consumers stop processing → increased lag."

### Q3: "How do you monitor Kafka in production?"

**Answer:**
"Key metrics:

**Consumer Health:**
- Consumer lag (messages behind)
- Messages consumed/sec
- Rebalance frequency
- Processing latency

**Broker Health:**
- Under-replicated partitions (availability risk)
- Leader election rate
- Request latency (p50, p95, p99)
- Disk usage

**Producer Health:**
- Message send rate
- Send failures
- Batch size

Tools: Kafka Manager, Confluent Control Center, Prometheus + Grafana, Azure Monitor (for Event Hubs)."

### Q4: "Kafka vs RabbitMQ - when to use which?"

**Answer:**
| Aspect | Kafka | RabbitMQ |
|--------|-------|----------|
| **Use Case** | Event streaming, log aggregation | Task queues, RPC |
| **Throughput** | Very high (millions/sec) | Moderate (tens of thousands/sec) |
| **Message retention** | Days-years | Until consumed |
| **Ordering** | Per partition | Per queue |
| **Consumers** | Pull-based | Push-based |
| **Complexity** | Higher (distributed system) | Lower |

**Choose Kafka:** Event-driven architectures, audit logs, real-time analytics, microservices communication
**Choose RabbitMQ:** Traditional message queuing, work distribution, priority queues, routing complexity"

### Q5: "How do you test Kafka consumers/producers?"

**Answer:**
```csharp
// Unit test with mock
public class OrderServiceTests
{
    [Fact]
    public async Task PublishOrderEvent_SendsToKafka()
    {
        var mockProducer = new Mock<IKafkaProducerService>();
        var service = new OrderService(mockProducer.Object);

        await service.CreateOrderAsync(new Order { Id = Guid.NewGuid() });

        mockProducer.Verify(p => p.SendSyncAsync(
            "orders",
            It.IsAny<string>(),
            It.IsAny<string>()), Times.Once);
    }
}

// Integration test with Testcontainers
public class KafkaIntegrationTests : IAsyncLifetime
{
    private KafkaContainer _kafkaContainer;

    public async Task InitializeAsync()
    {
        _kafkaContainer = new KafkaBuilder()
            .WithImage("confluentinc/cp-kafka:7.5.0")
            .Build();
        await _kafkaContainer.StartAsync();
    }

    [Fact]
    public async Task Producer_Consumer_EndToEnd()
    {
        var bootstrapServers = _kafkaContainer.GetBootstrapAddress();

        // Send message
        var producer = new ProducerBuilder<string, string>(new ProducerConfig
        {
            BootstrapServers = bootstrapServers
        }).Build();

        await producer.ProduceAsync("test-topic", new Message<string, string>
        {
            Key = "key1",
            Value = "value1"
        });

        // Consume message
        var consumer = new ConsumerBuilder<string, string>(new ConsumerConfig
        {
            BootstrapServers = bootstrapServers,
            GroupId = "test-group",
            AutoOffsetReset = AutoOffsetReset.Earliest
        }).Build();

        consumer.Subscribe("test-topic");
        var result = consumer.Consume(TimeSpan.FromSeconds(10));

        Assert.Equal("value1", result.Message.Value);
    }

    public async Task DisposeAsync() => await _kafkaContainer.StopAsync();
}
```"

---

## 10. Key Takeaways

**Tech Lead / Architect Level:**
1. **Partitioning is everything** - Determines throughput, ordering, and scalability
2. **Choose delivery guarantee** - At-least-once + idempotency is the sweet spot
3. **Monitor consumer lag** - Early warning system for production issues
4. **Rebalancing is expensive** - Design to minimize (CooperativeSticky, stable consumers)
5. **Key-based partitioning** - Ensures ordering where it matters (per customer, per tenant)
6. **Exactly-once is hard** - Use transactions only when absolutely necessary (payments, financial)
7. **Consumer groups = scaling** - Add consumers to handle more throughput
8. **Kafka != RabbitMQ** - Different tools for different jobs
9. **Event Hubs for Azure-native** - Managed Kafka alternative with seamless integration
10. **Test with Testcontainers** - Integration tests without manual Kafka setup

**Interview Preparation:**
- Be ready to whiteboard Kafka architecture (brokers, partitions, consumer groups)
- Explain exactly-once semantics and when to use it
- Discuss consumer lag and how to fix it
- Compare Kafka vs other messaging systems (RabbitMQ, SQS, Service Bus)
- Walk through a real scenario (order processing, payment, real-time tracking)

**Red Flags to Avoid:**
- ❌ "I commit offsets before processing messages" → Data loss!
- ❌ "I use auto-commit with async processing" → Offset committed before done!
- ❌ "I process messages in parallel within partition" → Breaks ordering!
- ❌ "I don't monitor consumer lag" → Production blindness!
- ❌ "I always use exactly-once" → Over-engineering, performance cost!
