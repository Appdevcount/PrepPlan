# Kafka Interview Questions for .NET Developers
## From Beginner to Expert

---

## Table of Contents
1. [Beginner Level](#beginner-level)
2. [Intermediate Level](#intermediate-level)
3. [Advanced Level](#advanced-level)
4. [Expert Level](#expert-level)

---

# Beginner Level

## 1. What is Apache Kafka?

**Answer:**
Apache Kafka is a distributed event streaming platform capable of handling trillions of events per day. It was originally developed by LinkedIn and later open-sourced through the Apache Software Foundation.

**Key characteristics:**
- **Distributed**: Runs as a cluster across multiple servers
- **Fault-tolerant**: Replicates data across multiple nodes
- **Scalable**: Can handle high throughput
- **Durable**: Persists messages to disk
- **Real-time**: Processes streams of records in real-time

**Common use cases:**
- Messaging system
- Activity tracking
- Log aggregation
- Stream processing
- Event sourcing

---

## 2. What are the core components of Kafka?

**Answer:**

| Component | Description |
|-----------|-------------|
| **Producer** | Application that sends/publishes messages to Kafka topics |
| **Consumer** | Application that reads/subscribes to messages from topics |
| **Broker** | Kafka server that stores and serves messages |
| **Topic** | Category/feed name to which records are published |
| **Partition** | Subdivision of a topic for parallel processing |
| **Consumer Group** | Group of consumers that cooperatively consume from topics |
| **ZooKeeper/KRaft** | Coordination service for Kafka cluster management |

```
┌─────────────┐     ┌─────────────────────────────────┐     ┌─────────────┐
│  Producer   │────▶│         Kafka Broker            │────▶│  Consumer   │
└─────────────┘     │  ┌─────────────────────────┐    │     └─────────────┘
                    │  │ Topic: orders           │    │
                    │  │  ├── Partition 0        │    │
                    │  │  ├── Partition 1        │    │
                    │  │  └── Partition 2        │    │
                    │  └─────────────────────────┘    │
                    └─────────────────────────────────┘
```

---

## 3. What is a Kafka Topic and Partition?

**Answer:**

**Topic:**
- A topic is a category or feed name to which records are published
- Topics are multi-subscriber (can have zero, one, or many consumers)
- Topics are identified by their name

**Partition:**
- Topics are split into partitions for scalability
- Each partition is an ordered, immutable sequence of records
- Each record within a partition gets a unique sequential ID called **offset**
- Partitions allow parallel processing

```csharp
// Example: Creating a topic programmatically in .NET
using Confluent.Kafka;
using Confluent.Kafka.Admin;

public async Task CreateTopicAsync()
{
    var config = new AdminClientConfig
    {
        BootstrapServers = "localhost:9092"
    };

    using var adminClient = new AdminClientBuilder(config).Build();

    try
    {
        await adminClient.CreateTopicsAsync(new TopicSpecification[]
        {
            new TopicSpecification
            {
                Name = "my-topic",
                NumPartitions = 3,
                ReplicationFactor = 1
            }
        });

        Console.WriteLine("Topic created successfully");
    }
    catch (CreateTopicsException ex)
    {
        Console.WriteLine($"Error creating topic: {ex.Results[0].Error.Reason}");
    }
}
```

---

## 4. What NuGet packages are needed for Kafka in .NET?

**Answer:**

The primary package is `Confluent.Kafka` - the official .NET client for Apache Kafka.

```bash
# Install via NuGet Package Manager
Install-Package Confluent.Kafka

# Or via .NET CLI
dotnet add package Confluent.Kafka
```

**Additional useful packages:**

```bash
# For Schema Registry support (Avro serialization)
dotnet add package Confluent.SchemaRegistry
dotnet add package Confluent.SchemaRegistry.Serdes.Avro

# For JSON serialization with Schema Registry
dotnet add package Confluent.SchemaRegistry.Serdes.Json

# For Protobuf serialization
dotnet add package Confluent.SchemaRegistry.Serdes.Protobuf
```

---

## 5. How do you create a simple Kafka Producer in .NET?

**Answer:**

```csharp
using Confluent.Kafka;

public class SimpleKafkaProducer
{
    private readonly IProducer<string, string> _producer;
    private readonly string _topic;

    public SimpleKafkaProducer(string bootstrapServers, string topic)
    {
        _topic = topic;

        var config = new ProducerConfig
        {
            BootstrapServers = bootstrapServers,
            ClientId = "my-dotnet-producer"
        };

        _producer = new ProducerBuilder<string, string>(config).Build();
    }

    public async Task<DeliveryResult<string, string>> ProduceAsync(string key, string message)
    {
        var kafkaMessage = new Message<string, string>
        {
            Key = key,
            Value = message
        };

        return await _producer.ProduceAsync(_topic, kafkaMessage);
    }

    // Fire-and-forget pattern (higher throughput)
    public void Produce(string key, string message)
    {
        _producer.Produce(_topic, new Message<string, string>
        {
            Key = key,
            Value = message
        }, deliveryReport =>
        {
            if (deliveryReport.Error.Code != ErrorCode.NoError)
            {
                Console.WriteLine($"Delivery failed: {deliveryReport.Error.Reason}");
            }
            else
            {
                Console.WriteLine($"Delivered to {deliveryReport.TopicPartitionOffset}");
            }
        });
    }

    public void Dispose()
    {
        _producer?.Flush(TimeSpan.FromSeconds(10));
        _producer?.Dispose();
    }
}

// Usage
class Program
{
    static async Task Main(string[] args)
    {
        var producer = new SimpleKafkaProducer("localhost:9092", "my-topic");

        var result = await producer.ProduceAsync("user-123", "Hello Kafka!");
        Console.WriteLine($"Message delivered to: {result.TopicPartitionOffset}");

        producer.Dispose();
    }
}
```

---

## 6. How do you create a simple Kafka Consumer in .NET?

**Answer:**

```csharp
using Confluent.Kafka;

public class SimpleKafkaConsumer
{
    private readonly IConsumer<string, string> _consumer;
    private readonly string _topic;
    private bool _consuming = true;

    public SimpleKafkaConsumer(string bootstrapServers, string groupId, string topic)
    {
        _topic = topic;

        var config = new ConsumerConfig
        {
            BootstrapServers = bootstrapServers,
            GroupId = groupId,
            AutoOffsetReset = AutoOffsetReset.Earliest,
            EnableAutoCommit = true
        };

        _consumer = new ConsumerBuilder<string, string>(config).Build();
    }

    public void StartConsuming(CancellationToken cancellationToken)
    {
        _consumer.Subscribe(_topic);

        try
        {
            while (!cancellationToken.IsCancellationRequested)
            {
                var consumeResult = _consumer.Consume(cancellationToken);

                Console.WriteLine($"Received message: Key={consumeResult.Message.Key}, " +
                                  $"Value={consumeResult.Message.Value}, " +
                                  $"Partition={consumeResult.Partition}, " +
                                  $"Offset={consumeResult.Offset}");
            }
        }
        catch (OperationCanceledException)
        {
            Console.WriteLine("Consumer cancelled");
        }
        finally
        {
            _consumer.Close();
        }
    }

    public void Dispose()
    {
        _consumer?.Dispose();
    }
}

// Usage
class Program
{
    static void Main(string[] args)
    {
        var cts = new CancellationTokenSource();
        Console.CancelKeyPress += (_, e) =>
        {
            e.Cancel = true;
            cts.Cancel();
        };

        var consumer = new SimpleKafkaConsumer("localhost:9092", "my-consumer-group", "my-topic");
        consumer.StartConsuming(cts.Token);
        consumer.Dispose();
    }
}
```

---

## 7. What is a Consumer Group?

**Answer:**

A **Consumer Group** is a group of consumers that work together to consume messages from a topic. Kafka ensures that each partition is consumed by only one consumer within a group.

**Key points:**
- Each consumer in a group reads from exclusive partitions
- If there are more consumers than partitions, some consumers remain idle
- If a consumer fails, its partitions are redistributed (rebalancing)
- Different consumer groups can independently consume the same messages

```
Topic: orders (3 partitions)
┌─────────────────────────────────────────────────────────────┐
│  Partition 0  │  Partition 1  │  Partition 2                │
└───────┬───────┴───────┬───────┴───────┬─────────────────────┘
        │               │               │
        ▼               ▼               ▼
┌─────────────────────────────────────────────────────────────┐
│              Consumer Group: "order-processors"              │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐                 │
│  │Consumer 1│   │Consumer 2│   │Consumer 3│                 │
│  │(P0)      │   │(P1)      │   │(P2)      │                 │
│  └──────────┘   └──────────┘   └──────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

```csharp
// Multiple consumers in the same group
var config = new ConsumerConfig
{
    BootstrapServers = "localhost:9092",
    GroupId = "order-processors", // Same group ID
    AutoOffsetReset = AutoOffsetReset.Earliest
};
```

---

## 8. What is the difference between `AutoOffsetReset.Earliest` and `AutoOffsetReset.Latest`?

**Answer:**

| Setting | Behavior |
|---------|----------|
| `Earliest` | Start reading from the beginning of the partition (oldest messages) |
| `Latest` | Start reading only new messages (from the end of the partition) |

**When does it apply?**
- Only when there's no committed offset for the consumer group
- Or when the committed offset is invalid (deleted due to retention)

```csharp
var config = new ConsumerConfig
{
    BootstrapServers = "localhost:9092",
    GroupId = "my-group",

    // Use Earliest to process historical messages
    AutoOffsetReset = AutoOffsetReset.Earliest,

    // Use Latest to only process new messages
    // AutoOffsetReset = AutoOffsetReset.Latest
};
```

**Use cases:**
- `Earliest`: Log processing, data migration, replay scenarios
- `Latest`: Real-time monitoring, live dashboards

---

# Intermediate Level

## 9. How do you implement manual offset commits?

**Answer:**

Manual offset commits give you control over when offsets are committed, ensuring at-least-once or exactly-once processing semantics.

```csharp
using Confluent.Kafka;

public class ManualCommitConsumer
{
    public void ConsumeWithManualCommit(CancellationToken cancellationToken)
    {
        var config = new ConsumerConfig
        {
            BootstrapServers = "localhost:9092",
            GroupId = "manual-commit-group",
            AutoOffsetReset = AutoOffsetReset.Earliest,
            EnableAutoCommit = false // Disable auto-commit
        };

        using var consumer = new ConsumerBuilder<string, string>(config).Build();
        consumer.Subscribe("my-topic");

        try
        {
            while (!cancellationToken.IsCancellationRequested)
            {
                var result = consumer.Consume(cancellationToken);

                try
                {
                    // Process the message
                    ProcessMessage(result.Message);

                    // Commit after successful processing
                    consumer.Commit(result);

                    Console.WriteLine($"Committed offset: {result.TopicPartitionOffset}");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Processing failed: {ex.Message}");
                    // Don't commit - message will be reprocessed
                }
            }
        }
        finally
        {
            consumer.Close();
        }
    }

    // Batch commit for better performance
    public void ConsumeWithBatchCommit(CancellationToken cancellationToken)
    {
        var config = new ConsumerConfig
        {
            BootstrapServers = "localhost:9092",
            GroupId = "batch-commit-group",
            EnableAutoCommit = false
        };

        using var consumer = new ConsumerBuilder<string, string>(config).Build();
        consumer.Subscribe("my-topic");

        const int batchSize = 100;
        var messageCount = 0;

        try
        {
            while (!cancellationToken.IsCancellationRequested)
            {
                var result = consumer.Consume(cancellationToken);
                ProcessMessage(result.Message);
                messageCount++;

                if (messageCount >= batchSize)
                {
                    consumer.Commit(); // Commits all consumed offsets
                    messageCount = 0;
                    Console.WriteLine("Batch committed");
                }
            }
        }
        finally
        {
            consumer.Commit(); // Commit remaining
            consumer.Close();
        }
    }

    private void ProcessMessage(Message<string, string> message)
    {
        // Your processing logic here
        Console.WriteLine($"Processing: {message.Value}");
    }
}
```

---

## 10. How do you serialize/deserialize complex objects in Kafka?

**Answer:**

You can use custom serializers or Schema Registry for complex types.

**Option 1: JSON Serialization (Simple)**

```csharp
using System.Text.Json;
using Confluent.Kafka;

public class Order
{
    public string OrderId { get; set; }
    public string CustomerId { get; set; }
    public decimal Amount { get; set; }
    public DateTime CreatedAt { get; set; }
}

// Custom JSON Serializer
public class JsonSerializer<T> : ISerializer<T>
{
    public byte[] Serialize(T data, SerializationContext context)
    {
        if (data == null) return null;
        return JsonSerializer.SerializeToUtf8Bytes(data);
    }
}

// Custom JSON Deserializer
public class JsonDeserializer<T> : IDeserializer<T>
{
    public T Deserialize(ReadOnlySpan<byte> data, bool isNull, SerializationContext context)
    {
        if (isNull) return default;
        return JsonSerializer.Deserialize<T>(data);
    }
}

// Producer with custom serializer
public class OrderProducer
{
    private readonly IProducer<string, Order> _producer;

    public OrderProducer(string bootstrapServers)
    {
        var config = new ProducerConfig { BootstrapServers = bootstrapServers };

        _producer = new ProducerBuilder<string, Order>(config)
            .SetValueSerializer(new JsonSerializer<Order>())
            .Build();
    }

    public async Task ProduceOrderAsync(Order order)
    {
        await _producer.ProduceAsync("orders", new Message<string, Order>
        {
            Key = order.OrderId,
            Value = order
        });
    }
}

// Consumer with custom deserializer
public class OrderConsumer
{
    private readonly IConsumer<string, Order> _consumer;

    public OrderConsumer(string bootstrapServers, string groupId)
    {
        var config = new ConsumerConfig
        {
            BootstrapServers = bootstrapServers,
            GroupId = groupId
        };

        _consumer = new ConsumerBuilder<string, Order>(config)
            .SetValueDeserializer(new JsonDeserializer<Order>())
            .Build();
    }
}
```

**Option 2: Using Confluent Schema Registry (Production-ready)**

```csharp
using Confluent.Kafka;
using Confluent.SchemaRegistry;
using Confluent.SchemaRegistry.Serdes;

public class SchemaRegistryProducer
{
    public async Task ProduceWithSchemaRegistry()
    {
        var schemaRegistryConfig = new SchemaRegistryConfig
        {
            Url = "http://localhost:8081"
        };

        var producerConfig = new ProducerConfig
        {
            BootstrapServers = "localhost:9092"
        };

        using var schemaRegistry = new CachedSchemaRegistryClient(schemaRegistryConfig);

        using var producer = new ProducerBuilder<string, Order>(producerConfig)
            .SetValueSerializer(new JsonSerializer<Order>(schemaRegistry))
            .Build();

        var order = new Order
        {
            OrderId = "ORD-001",
            CustomerId = "CUST-123",
            Amount = 99.99m,
            CreatedAt = DateTime.UtcNow
        };

        await producer.ProduceAsync("orders", new Message<string, Order>
        {
            Key = order.OrderId,
            Value = order
        });
    }
}
```

---

## 11. How do you handle Producer errors and retries?

**Answer:**

```csharp
using Confluent.Kafka;

public class ResilientProducer
{
    private readonly IProducer<string, string> _producer;

    public ResilientProducer(string bootstrapServers)
    {
        var config = new ProducerConfig
        {
            BootstrapServers = bootstrapServers,

            // Retry configuration
            MessageSendMaxRetries = 3,
            RetryBackoffMs = 1000,

            // Idempotence (prevents duplicates on retry)
            EnableIdempotence = true,

            // Acknowledgment settings
            Acks = Acks.All, // Wait for all replicas

            // Timeout settings
            MessageTimeoutMs = 30000,
            RequestTimeoutMs = 5000,

            // Batch settings for performance
            BatchSize = 16384,
            LingerMs = 5,

            // Compression
            CompressionType = CompressionType.Snappy
        };

        _producer = new ProducerBuilder<string, string>(config)
            .SetErrorHandler((_, error) =>
            {
                Console.WriteLine($"Producer error: {error.Reason}");
                // Log to monitoring system
            })
            .SetLogHandler((_, log) =>
            {
                Console.WriteLine($"Producer log: {log.Message}");
            })
            .Build();
    }

    public async Task<bool> ProduceWithRetryAsync(string topic, string key, string value)
    {
        const int maxAttempts = 3;

        for (int attempt = 1; attempt <= maxAttempts; attempt++)
        {
            try
            {
                var result = await _producer.ProduceAsync(topic, new Message<string, string>
                {
                    Key = key,
                    Value = value
                });

                Console.WriteLine($"Delivered to {result.TopicPartitionOffset}");
                return true;
            }
            catch (ProduceException<string, string> ex)
            {
                Console.WriteLine($"Attempt {attempt} failed: {ex.Error.Reason}");

                if (ex.Error.IsFatal)
                {
                    Console.WriteLine("Fatal error - not retrying");
                    throw;
                }

                if (attempt < maxAttempts)
                {
                    await Task.Delay(TimeSpan.FromSeconds(Math.Pow(2, attempt)));
                }
            }
        }

        return false;
    }

    public void Dispose()
    {
        _producer?.Flush(TimeSpan.FromSeconds(30));
        _producer?.Dispose();
    }
}
```

---

## 12. How do you handle Consumer rebalancing?

**Answer:**

Rebalancing occurs when consumers join/leave a group or partitions are added. Handle it to ensure proper cleanup and state management.

```csharp
using Confluent.Kafka;

public class RebalanceAwareConsumer
{
    private readonly Dictionary<TopicPartition, long> _partitionOffsets = new();
    private readonly Dictionary<TopicPartition, object> _partitionState = new();

    public void ConsumeWithRebalanceHandling(CancellationToken cancellationToken)
    {
        var config = new ConsumerConfig
        {
            BootstrapServers = "localhost:9092",
            GroupId = "rebalance-aware-group",
            EnableAutoCommit = false,
            AutoOffsetReset = AutoOffsetReset.Earliest,

            // Partition assignment strategy
            PartitionAssignmentStrategy = PartitionAssignmentStrategy.CooperativeSticky
        };

        using var consumer = new ConsumerBuilder<string, string>(config)
            .SetPartitionsAssignedHandler((c, partitions) =>
            {
                Console.WriteLine($"Partitions assigned: [{string.Join(", ", partitions)}]");

                foreach (var tp in partitions)
                {
                    // Initialize state for new partitions
                    _partitionState[tp] = InitializePartitionState(tp);
                    Console.WriteLine($"Initialized state for {tp}");
                }
            })
            .SetPartitionsRevokedHandler((c, partitions) =>
            {
                Console.WriteLine($"Partitions revoked: [{string.Join(", ", partitions)}]");

                // Commit offsets before losing partitions
                var offsets = partitions
                    .Where(tp => _partitionOffsets.ContainsKey(tp))
                    .Select(tp => new TopicPartitionOffset(tp, _partitionOffsets[tp] + 1))
                    .ToList();

                if (offsets.Any())
                {
                    c.Commit(offsets);
                    Console.WriteLine("Committed offsets before revocation");
                }

                // Clean up state
                foreach (var tp in partitions)
                {
                    CleanupPartitionState(tp);
                    _partitionState.Remove(tp);
                    _partitionOffsets.Remove(tp);
                }
            })
            .SetPartitionsLostHandler((c, partitions) =>
            {
                // Partitions lost unexpectedly (cannot commit)
                Console.WriteLine($"Partitions lost: [{string.Join(", ", partitions)}]");

                foreach (var tp in partitions)
                {
                    CleanupPartitionState(tp);
                    _partitionState.Remove(tp);
                    _partitionOffsets.Remove(tp);
                }
            })
            .Build();

        consumer.Subscribe("my-topic");

        try
        {
            while (!cancellationToken.IsCancellationRequested)
            {
                var result = consumer.Consume(cancellationToken);

                // Process message
                ProcessMessage(result);

                // Track offset
                _partitionOffsets[result.TopicPartition] = result.Offset;
            }
        }
        finally
        {
            consumer.Close();
        }
    }

    private object InitializePartitionState(TopicPartition partition)
    {
        // Initialize any partition-specific state
        return new { Partition = partition, StartTime = DateTime.UtcNow };
    }

    private void CleanupPartitionState(TopicPartition partition)
    {
        // Clean up resources, flush buffers, etc.
        Console.WriteLine($"Cleaning up state for {partition}");
    }

    private void ProcessMessage(ConsumeResult<string, string> result)
    {
        Console.WriteLine($"Processing: {result.Message.Value}");
    }
}
```

---

## 13. How do you implement a Kafka producer/consumer as a Hosted Service in ASP.NET Core?

**Answer:**

```csharp
// appsettings.json
/*
{
  "Kafka": {
    "BootstrapServers": "localhost:9092",
    "ProducerTopic": "orders",
    "ConsumerTopic": "orders",
    "ConsumerGroupId": "order-processor"
  }
}
*/

// KafkaSettings.cs
public class KafkaSettings
{
    public string BootstrapServers { get; set; }
    public string ProducerTopic { get; set; }
    public string ConsumerTopic { get; set; }
    public string ConsumerGroupId { get; set; }
}

// IKafkaProducerService.cs
public interface IKafkaProducerService
{
    Task ProduceAsync<T>(string key, T message);
}

// KafkaProducerService.cs
using Confluent.Kafka;
using Microsoft.Extensions.Options;
using System.Text.Json;

public class KafkaProducerService : IKafkaProducerService, IDisposable
{
    private readonly IProducer<string, string> _producer;
    private readonly KafkaSettings _settings;
    private readonly ILogger<KafkaProducerService> _logger;

    public KafkaProducerService(
        IOptions<KafkaSettings> settings,
        ILogger<KafkaProducerService> logger)
    {
        _settings = settings.Value;
        _logger = logger;

        var config = new ProducerConfig
        {
            BootstrapServers = _settings.BootstrapServers,
            EnableIdempotence = true,
            Acks = Acks.All
        };

        _producer = new ProducerBuilder<string, string>(config).Build();
    }

    public async Task ProduceAsync<T>(string key, T message)
    {
        var json = JsonSerializer.Serialize(message);

        try
        {
            var result = await _producer.ProduceAsync(_settings.ProducerTopic,
                new Message<string, string> { Key = key, Value = json });

            _logger.LogInformation("Produced message to {TopicPartitionOffset}",
                result.TopicPartitionOffset);
        }
        catch (ProduceException<string, string> ex)
        {
            _logger.LogError(ex, "Failed to produce message");
            throw;
        }
    }

    public void Dispose()
    {
        _producer?.Flush(TimeSpan.FromSeconds(10));
        _producer?.Dispose();
    }
}

// KafkaConsumerService.cs (Background Service)
using Confluent.Kafka;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Options;

public class KafkaConsumerService : BackgroundService
{
    private readonly KafkaSettings _settings;
    private readonly ILogger<KafkaConsumerService> _logger;
    private readonly IServiceProvider _serviceProvider;
    private IConsumer<string, string> _consumer;

    public KafkaConsumerService(
        IOptions<KafkaSettings> settings,
        ILogger<KafkaConsumerService> logger,
        IServiceProvider serviceProvider)
    {
        _settings = settings.Value;
        _logger = logger;
        _serviceProvider = serviceProvider;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await Task.Yield(); // Prevent blocking startup

        var config = new ConsumerConfig
        {
            BootstrapServers = _settings.BootstrapServers,
            GroupId = _settings.ConsumerGroupId,
            AutoOffsetReset = AutoOffsetReset.Earliest,
            EnableAutoCommit = false
        };

        _consumer = new ConsumerBuilder<string, string>(config)
            .SetErrorHandler((_, error) =>
                _logger.LogError("Consumer error: {Reason}", error.Reason))
            .Build();

        _consumer.Subscribe(_settings.ConsumerTopic);

        _logger.LogInformation("Kafka consumer started");

        try
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    var result = _consumer.Consume(stoppingToken);

                    using var scope = _serviceProvider.CreateScope();
                    var handler = scope.ServiceProvider
                        .GetRequiredService<IMessageHandler>();

                    await handler.HandleAsync(result.Message.Key, result.Message.Value);

                    _consumer.Commit(result);
                }
                catch (ConsumeException ex)
                {
                    _logger.LogError(ex, "Consume error");
                }
            }
        }
        catch (OperationCanceledException)
        {
            _logger.LogInformation("Consumer stopping");
        }
        finally
        {
            _consumer.Close();
            _consumer.Dispose();
        }
    }
}

// IMessageHandler.cs
public interface IMessageHandler
{
    Task HandleAsync(string key, string message);
}

// Program.cs / Startup.cs
public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        // Configure Kafka settings
        builder.Services.Configure<KafkaSettings>(
            builder.Configuration.GetSection("Kafka"));

        // Register services
        builder.Services.AddSingleton<IKafkaProducerService, KafkaProducerService>();
        builder.Services.AddScoped<IMessageHandler, OrderMessageHandler>();
        builder.Services.AddHostedService<KafkaConsumerService>();

        var app = builder.Build();
        app.Run();
    }
}
```

---

## 14. How do you send messages to specific partitions?

**Answer:**

```csharp
using Confluent.Kafka;

public class PartitionedProducer
{
    private readonly IProducer<string, string> _producer;

    public PartitionedProducer(string bootstrapServers)
    {
        var config = new ProducerConfig { BootstrapServers = bootstrapServers };
        _producer = new ProducerBuilder<string, string>(config).Build();
    }

    // Method 1: Specify partition explicitly
    public async Task ProduceToSpecificPartition(string topic, int partition, string key, string value)
    {
        var topicPartition = new TopicPartition(topic, new Partition(partition));

        await _producer.ProduceAsync(topicPartition, new Message<string, string>
        {
            Key = key,
            Value = value
        });
    }

    // Method 2: Use custom partitioner
    public IProducer<string, string> CreateProducerWithCustomPartitioner(string bootstrapServers)
    {
        var config = new ProducerConfig { BootstrapServers = bootstrapServers };

        return new ProducerBuilder<string, string>(config)
            .SetPartitioner("my-topic", (topic, partitionCount, keyData, keyIsNull) =>
            {
                if (keyIsNull)
                    return Partition.Any;

                // Custom logic: hash the key to determine partition
                var key = System.Text.Encoding.UTF8.GetString(keyData);

                // Example: Route by customer region
                if (key.StartsWith("US-"))
                    return new Partition(0);
                if (key.StartsWith("EU-"))
                    return new Partition(1);
                if (key.StartsWith("ASIA-"))
                    return new Partition(2);

                // Default: murmur2 hash
                return new Partition(Math.Abs(key.GetHashCode()) % partitionCount);
            })
            .Build();
    }

    // Method 3: Consume from specific partitions (manual assignment)
    public void ConsumeFromSpecificPartitions()
    {
        var config = new ConsumerConfig
        {
            BootstrapServers = "localhost:9092",
            GroupId = "manual-assignment-group"
        };

        using var consumer = new ConsumerBuilder<string, string>(config).Build();

        // Assign specific partitions instead of subscribing
        consumer.Assign(new List<TopicPartitionOffset>
        {
            new TopicPartitionOffset("my-topic", 0, Offset.Beginning),
            new TopicPartitionOffset("my-topic", 2, Offset.Beginning)
        });

        // Now consume only from partitions 0 and 2
        var result = consumer.Consume(TimeSpan.FromSeconds(10));
    }
}
```

---

## 15. How do you implement message headers in Kafka?

**Answer:**

Message headers are key-value pairs attached to messages for metadata, tracing, and routing.

```csharp
using Confluent.Kafka;
using System.Text;

public class HeadersExample
{
    public async Task ProduceWithHeaders(string bootstrapServers)
    {
        var config = new ProducerConfig { BootstrapServers = bootstrapServers };
        using var producer = new ProducerBuilder<string, string>(config).Build();

        var message = new Message<string, string>
        {
            Key = "order-123",
            Value = "{\"amount\": 100}",
            Headers = new Headers
            {
                { "correlation-id", Encoding.UTF8.GetBytes(Guid.NewGuid().ToString()) },
                { "source-system", Encoding.UTF8.GetBytes("order-service") },
                { "content-type", Encoding.UTF8.GetBytes("application/json") },
                { "timestamp", Encoding.UTF8.GetBytes(DateTime.UtcNow.ToString("O")) },
                { "user-id", Encoding.UTF8.GetBytes("user-456") }
            }
        };

        await producer.ProduceAsync("orders", message);
    }

    public void ConsumeWithHeaders(CancellationToken cancellationToken)
    {
        var config = new ConsumerConfig
        {
            BootstrapServers = "localhost:9092",
            GroupId = "header-consumer-group"
        };

        using var consumer = new ConsumerBuilder<string, string>(config).Build();
        consumer.Subscribe("orders");

        while (!cancellationToken.IsCancellationRequested)
        {
            var result = consumer.Consume(cancellationToken);

            // Read headers
            var correlationId = GetHeaderValue(result.Message.Headers, "correlation-id");
            var sourceSystem = GetHeaderValue(result.Message.Headers, "source-system");
            var contentType = GetHeaderValue(result.Message.Headers, "content-type");

            Console.WriteLine($"Correlation ID: {correlationId}");
            Console.WriteLine($"Source: {sourceSystem}");
            Console.WriteLine($"Content-Type: {contentType}");
            Console.WriteLine($"Value: {result.Message.Value}");
        }
    }

    private string GetHeaderValue(Headers headers, string key)
    {
        var header = headers.FirstOrDefault(h => h.Key == key);
        return header != null
            ? Encoding.UTF8.GetString(header.GetValueBytes())
            : null;
    }
}

// Distributed Tracing with Headers
public class TracingProducer
{
    public async Task ProduceWithTracing(IProducer<string, string> producer,
        string topic, string key, string value, Activity activity)
    {
        var headers = new Headers();

        // Propagate trace context
        if (activity != null)
        {
            headers.Add("traceparent",
                Encoding.UTF8.GetBytes($"00-{activity.TraceId}-{activity.SpanId}-01"));

            if (!string.IsNullOrEmpty(activity.TraceStateString))
            {
                headers.Add("tracestate",
                    Encoding.UTF8.GetBytes(activity.TraceStateString));
            }
        }

        await producer.ProduceAsync(topic, new Message<string, string>
        {
            Key = key,
            Value = value,
            Headers = headers
        });
    }
}
```

---

# Advanced Level

## 16. How do you implement exactly-once semantics in Kafka with .NET?

**Answer:**

Exactly-once semantics (EOS) ensures messages are neither lost nor duplicated. This requires idempotent producers and transactional processing.

```csharp
using Confluent.Kafka;

public class ExactlyOnceProducer : IDisposable
{
    private readonly IProducer<string, string> _producer;

    public ExactlyOnceProducer(string bootstrapServers, string transactionalId)
    {
        var config = new ProducerConfig
        {
            BootstrapServers = bootstrapServers,

            // Enable idempotence
            EnableIdempotence = true,

            // Transactional ID for exactly-once
            TransactionalId = transactionalId,

            // Required for transactions
            Acks = Acks.All,

            // Recommended settings
            MaxInFlight = 5, // Max with idempotence
            MessageSendMaxRetries = int.MaxValue,
            LingerMs = 5
        };

        _producer = new ProducerBuilder<string, string>(config).Build();

        // Initialize transactions (call once)
        _producer.InitTransactions(TimeSpan.FromSeconds(30));
    }

    public async Task ProduceInTransactionAsync(
        List<(string topic, string key, string value)> messages)
    {
        try
        {
            // Begin transaction
            _producer.BeginTransaction();

            foreach (var (topic, key, value) in messages)
            {
                await _producer.ProduceAsync(topic, new Message<string, string>
                {
                    Key = key,
                    Value = value
                });
            }

            // Commit transaction
            _producer.CommitTransaction();
            Console.WriteLine("Transaction committed successfully");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Transaction failed: {ex.Message}");

            // Abort transaction
            _producer.AbortTransaction();
            throw;
        }
    }

    public void Dispose()
    {
        _producer?.Dispose();
    }
}

// Transactional Consumer-Producer (Read-Process-Write pattern)
public class TransactionalProcessor : IDisposable
{
    private readonly IConsumer<string, string> _consumer;
    private readonly IProducer<string, string> _producer;

    public TransactionalProcessor(string bootstrapServers,
        string groupId, string transactionalId)
    {
        var consumerConfig = new ConsumerConfig
        {
            BootstrapServers = bootstrapServers,
            GroupId = groupId,
            EnableAutoCommit = false,
            IsolationLevel = IsolationLevel.ReadCommitted // Only read committed messages
        };

        var producerConfig = new ProducerConfig
        {
            BootstrapServers = bootstrapServers,
            TransactionalId = transactionalId,
            EnableIdempotence = true,
            Acks = Acks.All
        };

        _consumer = new ConsumerBuilder<string, string>(consumerConfig).Build();
        _producer = new ProducerBuilder<string, string>(producerConfig).Build();

        _producer.InitTransactions(TimeSpan.FromSeconds(30));
    }

    public void ProcessWithExactlyOnce(string inputTopic, string outputTopic,
        CancellationToken cancellationToken)
    {
        _consumer.Subscribe(inputTopic);

        while (!cancellationToken.IsCancellationRequested)
        {
            var consumeResult = _consumer.Consume(cancellationToken);

            try
            {
                _producer.BeginTransaction();

                // Process and produce
                var processedValue = ProcessMessage(consumeResult.Message.Value);

                _producer.Produce(outputTopic, new Message<string, string>
                {
                    Key = consumeResult.Message.Key,
                    Value = processedValue
                });

                // Send consumer offsets as part of transaction
                _producer.SendOffsetsToTransaction(
                    new List<TopicPartitionOffset>
                    {
                        new TopicPartitionOffset(
                            consumeResult.TopicPartition,
                            consumeResult.Offset + 1)
                    },
                    _consumer.ConsumerGroupMetadata,
                    TimeSpan.FromSeconds(30));

                _producer.CommitTransaction();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                _producer.AbortTransaction();
            }
        }
    }

    private string ProcessMessage(string input)
    {
        // Your processing logic
        return $"Processed: {input}";
    }

    public void Dispose()
    {
        _consumer?.Close();
        _consumer?.Dispose();
        _producer?.Dispose();
    }
}
```

---

## 17. How do you implement dead letter queues (DLQ) in Kafka?

**Answer:**

A Dead Letter Queue captures messages that fail processing after multiple retries.

```csharp
using Confluent.Kafka;
using System.Text.Json;

public class DeadLetterQueueConsumer
{
    private readonly ConsumerConfig _consumerConfig;
    private readonly ProducerConfig _producerConfig;
    private readonly string _mainTopic;
    private readonly string _dlqTopic;
    private readonly string _retryTopic;
    private readonly int _maxRetries;

    public DeadLetterQueueConsumer(
        string bootstrapServers,
        string groupId,
        string mainTopic,
        int maxRetries = 3)
    {
        _mainTopic = mainTopic;
        _dlqTopic = $"{mainTopic}.dlq";
        _retryTopic = $"{mainTopic}.retry";
        _maxRetries = maxRetries;

        _consumerConfig = new ConsumerConfig
        {
            BootstrapServers = bootstrapServers,
            GroupId = groupId,
            EnableAutoCommit = false,
            AutoOffsetReset = AutoOffsetReset.Earliest
        };

        _producerConfig = new ProducerConfig
        {
            BootstrapServers = bootstrapServers,
            EnableIdempotence = true
        };
    }

    public async Task ConsumeWithDlq(CancellationToken cancellationToken)
    {
        using var consumer = new ConsumerBuilder<string, string>(_consumerConfig).Build();
        using var producer = new ProducerBuilder<string, string>(_producerConfig).Build();

        consumer.Subscribe(new[] { _mainTopic, _retryTopic });

        while (!cancellationToken.IsCancellationRequested)
        {
            var result = consumer.Consume(cancellationToken);

            var retryCount = GetRetryCount(result.Message.Headers);

            try
            {
                await ProcessMessageAsync(result.Message);
                consumer.Commit(result);
            }
            catch (Exception ex)
            {
                if (retryCount >= _maxRetries)
                {
                    // Send to DLQ
                    await SendToDlqAsync(producer, result, ex);
                    Console.WriteLine($"Message sent to DLQ after {retryCount} retries");
                }
                else
                {
                    // Send to retry topic
                    await SendToRetryAsync(producer, result, retryCount + 1);
                    Console.WriteLine($"Message sent to retry (attempt {retryCount + 1})");
                }

                consumer.Commit(result);
            }
        }
    }

    private async Task ProcessMessageAsync(Message<string, string> message)
    {
        // Simulate processing that might fail
        var random = new Random();
        if (random.Next(10) < 3) // 30% failure rate for demo
        {
            throw new Exception("Processing failed");
        }

        Console.WriteLine($"Successfully processed: {message.Value}");
        await Task.CompletedTask;
    }

    private int GetRetryCount(Headers headers)
    {
        var header = headers?.FirstOrDefault(h => h.Key == "retry-count");
        if (header == null) return 0;

        return int.Parse(Encoding.UTF8.GetString(header.GetValueBytes()));
    }

    private async Task SendToRetryAsync(
        IProducer<string, string> producer,
        ConsumeResult<string, string> original,
        int retryCount)
    {
        var headers = new Headers(original.Message.Headers ?? new Headers());

        // Update retry count
        headers.Remove("retry-count");
        headers.Add("retry-count", Encoding.UTF8.GetBytes(retryCount.ToString()));
        headers.Add("retry-timestamp", Encoding.UTF8.GetBytes(DateTime.UtcNow.ToString("O")));
        headers.Add("original-topic", Encoding.UTF8.GetBytes(original.Topic));

        await producer.ProduceAsync(_retryTopic, new Message<string, string>
        {
            Key = original.Message.Key,
            Value = original.Message.Value,
            Headers = headers
        });
    }

    private async Task SendToDlqAsync(
        IProducer<string, string> producer,
        ConsumeResult<string, string> original,
        Exception error)
    {
        var headers = new Headers(original.Message.Headers ?? new Headers());

        headers.Add("error-message", Encoding.UTF8.GetBytes(error.Message));
        headers.Add("error-type", Encoding.UTF8.GetBytes(error.GetType().Name));
        headers.Add("failed-timestamp", Encoding.UTF8.GetBytes(DateTime.UtcNow.ToString("O")));
        headers.Add("original-topic", Encoding.UTF8.GetBytes(original.Topic));
        headers.Add("original-partition", Encoding.UTF8.GetBytes(original.Partition.ToString()));
        headers.Add("original-offset", Encoding.UTF8.GetBytes(original.Offset.ToString()));

        // Create DLQ message with metadata
        var dlqMessage = new
        {
            OriginalMessage = original.Message.Value,
            Error = error.Message,
            StackTrace = error.StackTrace,
            FailedAt = DateTime.UtcNow,
            RetryCount = GetRetryCount(original.Message.Headers)
        };

        await producer.ProduceAsync(_dlqTopic, new Message<string, string>
        {
            Key = original.Message.Key,
            Value = JsonSerializer.Serialize(dlqMessage),
            Headers = headers
        });
    }
}

// DLQ Processor for manual review/retry
public class DlqProcessor
{
    public async Task ReprocessDlqMessage(
        IProducer<string, string> producer,
        ConsumeResult<string, string> dlqMessage,
        string originalTopic)
    {
        // Parse DLQ message
        var dlqContent = JsonSerializer.Deserialize<DlqMessageContent>(dlqMessage.Message.Value);

        // Reset headers and send back to main topic
        var headers = new Headers
        {
            { "reprocessed-from-dlq", Encoding.UTF8.GetBytes("true") },
            { "reprocessed-at", Encoding.UTF8.GetBytes(DateTime.UtcNow.ToString("O")) }
        };

        await producer.ProduceAsync(originalTopic, new Message<string, string>
        {
            Key = dlqMessage.Message.Key,
            Value = dlqContent.OriginalMessage,
            Headers = headers
        });
    }

    private class DlqMessageContent
    {
        public string OriginalMessage { get; set; }
        public string Error { get; set; }
        public DateTime FailedAt { get; set; }
    }
}
```

---

## 18. How do you implement consumer lag monitoring?

**Answer:**

Consumer lag is the difference between the latest offset and the committed offset.

```csharp
using Confluent.Kafka;
using Confluent.Kafka.Admin;

public class ConsumerLagMonitor
{
    private readonly string _bootstrapServers;
    private readonly ILogger<ConsumerLagMonitor> _logger;

    public ConsumerLagMonitor(string bootstrapServers, ILogger<ConsumerLagMonitor> logger)
    {
        _bootstrapServers = bootstrapServers;
        _logger = logger;
    }

    public async Task<Dictionary<TopicPartition, long>> GetConsumerLagAsync(
        string groupId, string topic)
    {
        var lag = new Dictionary<TopicPartition, long>();

        var adminConfig = new AdminClientConfig { BootstrapServers = _bootstrapServers };
        var consumerConfig = new ConsumerConfig
        {
            BootstrapServers = _bootstrapServers,
            GroupId = groupId
        };

        using var adminClient = new AdminClientBuilder(adminConfig).Build();
        using var consumer = new ConsumerBuilder<string, string>(consumerConfig).Build();

        // Get topic metadata
        var metadata = adminClient.GetMetadata(topic, TimeSpan.FromSeconds(10));
        var topicMetadata = metadata.Topics.First(t => t.Topic == topic);

        var partitions = topicMetadata.Partitions
            .Select(p => new TopicPartition(topic, p.PartitionId))
            .ToList();

        // Get committed offsets for the consumer group
        var committed = consumer.Committed(partitions, TimeSpan.FromSeconds(10));

        // Get end offsets (high watermarks)
        var watermarkOffsets = new Dictionary<TopicPartition, WatermarkOffsets>();
        foreach (var tp in partitions)
        {
            watermarkOffsets[tp] = consumer.QueryWatermarkOffsets(tp, TimeSpan.FromSeconds(10));
        }

        // Calculate lag
        foreach (var tp in partitions)
        {
            var committedOffset = committed
                .FirstOrDefault(c => c.TopicPartition == tp)?.Offset.Value ?? 0;

            var highWatermark = watermarkOffsets[tp].High.Value;

            lag[tp] = highWatermark - committedOffset;
        }

        return lag;
    }

    // Background service for continuous monitoring
    public async Task MonitorLagContinuouslyAsync(
        string groupId,
        string topic,
        TimeSpan interval,
        long lagThreshold,
        CancellationToken cancellationToken)
    {
        while (!cancellationToken.IsCancellationRequested)
        {
            try
            {
                var lag = await GetConsumerLagAsync(groupId, topic);
                var totalLag = lag.Values.Sum();

                foreach (var (partition, partitionLag) in lag)
                {
                    _logger.LogInformation(
                        "Consumer group {GroupId} - {Partition}: Lag = {Lag}",
                        groupId, partition, partitionLag);

                    if (partitionLag > lagThreshold)
                    {
                        _logger.LogWarning(
                            "HIGH LAG ALERT: {Partition} has lag of {Lag} (threshold: {Threshold})",
                            partition, partitionLag, lagThreshold);

                        // Trigger alert (e.g., send to monitoring system)
                        await SendAlertAsync(groupId, partition, partitionLag);
                    }
                }

                _logger.LogInformation("Total lag for {GroupId}: {TotalLag}", groupId, totalLag);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error monitoring consumer lag");
            }

            await Task.Delay(interval, cancellationToken);
        }
    }

    private Task SendAlertAsync(string groupId, TopicPartition partition, long lag)
    {
        // Integrate with your alerting system (PagerDuty, Slack, etc.)
        return Task.CompletedTask;
    }
}

// Hosted service for lag monitoring
public class LagMonitoringService : BackgroundService
{
    private readonly ConsumerLagMonitor _monitor;
    private readonly IConfiguration _configuration;

    public LagMonitoringService(
        ConsumerLagMonitor monitor,
        IConfiguration configuration)
    {
        _monitor = monitor;
        _configuration = configuration;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var groupId = _configuration["Kafka:ConsumerGroupId"];
        var topic = _configuration["Kafka:Topic"];
        var threshold = _configuration.GetValue<long>("Kafka:LagThreshold", 10000);

        await _monitor.MonitorLagContinuouslyAsync(
            groupId,
            topic,
            TimeSpan.FromSeconds(30),
            threshold,
            stoppingToken);
    }
}
```

---

## 19. How do you implement parallel message processing with consumers?

**Answer:**

```csharp
using Confluent.Kafka;
using System.Threading.Channels;

public class ParallelMessageProcessor
{
    private readonly ConsumerConfig _consumerConfig;
    private readonly int _processorCount;
    private readonly Channel<ConsumeResult<string, string>> _channel;

    public ParallelMessageProcessor(
        string bootstrapServers,
        string groupId,
        int processorCount = 4)
    {
        _processorCount = processorCount;

        _consumerConfig = new ConsumerConfig
        {
            BootstrapServers = bootstrapServers,
            GroupId = groupId,
            EnableAutoCommit = false,
            MaxPollIntervalMs = 300000 // 5 minutes
        };

        // Bounded channel for backpressure
        _channel = Channel.CreateBounded<ConsumeResult<string, string>>(
            new BoundedChannelOptions(1000)
            {
                FullMode = BoundedChannelFullMode.Wait
            });
    }

    public async Task StartAsync(string topic, CancellationToken cancellationToken)
    {
        // Start processor tasks
        var processorTasks = Enumerable.Range(0, _processorCount)
            .Select(i => ProcessMessagesAsync(i, cancellationToken))
            .ToList();

        // Consumer task
        var consumerTask = ConsumeMessagesAsync(topic, cancellationToken);

        await Task.WhenAll(processorTasks.Append(consumerTask));
    }

    private async Task ConsumeMessagesAsync(string topic, CancellationToken cancellationToken)
    {
        using var consumer = new ConsumerBuilder<string, string>(_consumerConfig).Build();
        consumer.Subscribe(topic);

        try
        {
            while (!cancellationToken.IsCancellationRequested)
            {
                var result = consumer.Consume(cancellationToken);
                await _channel.Writer.WriteAsync(result, cancellationToken);
            }
        }
        finally
        {
            _channel.Writer.Complete();
            consumer.Close();
        }
    }

    private async Task ProcessMessagesAsync(int processorId, CancellationToken cancellationToken)
    {
        await foreach (var result in _channel.Reader.ReadAllAsync(cancellationToken))
        {
            try
            {
                await ProcessMessageAsync(result, processorId);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Processor {processorId} error: {ex.Message}");
            }
        }
    }

    private async Task ProcessMessageAsync(ConsumeResult<string, string> result, int processorId)
    {
        Console.WriteLine($"Processor {processorId} handling: {result.Message.Key}");
        await Task.Delay(100); // Simulate work
    }
}

// Alternative: Partition-based parallelism with ordering guarantee
public class PartitionParallelConsumer
{
    private readonly ConcurrentDictionary<int, Channel<ConsumeResult<string, string>>> _partitionChannels;
    private readonly ConsumerConfig _consumerConfig;

    public PartitionParallelConsumer(string bootstrapServers, string groupId)
    {
        _partitionChannels = new ConcurrentDictionary<int, Channel<ConsumeResult<string, string>>>();

        _consumerConfig = new ConsumerConfig
        {
            BootstrapServers = bootstrapServers,
            GroupId = groupId,
            EnableAutoCommit = false
        };
    }

    public async Task StartAsync(string topic, CancellationToken cancellationToken)
    {
        using var consumer = new ConsumerBuilder<string, string>(_consumerConfig)
            .SetPartitionsAssignedHandler((c, partitions) =>
            {
                foreach (var tp in partitions)
                {
                    var channel = Channel.CreateUnbounded<ConsumeResult<string, string>>();
                    _partitionChannels[tp.Partition.Value] = channel;

                    // Start processor for this partition
                    _ = ProcessPartitionAsync(tp.Partition.Value, channel.Reader, cancellationToken);
                }
            })
            .SetPartitionsRevokedHandler((c, partitions) =>
            {
                foreach (var tp in partitions)
                {
                    if (_partitionChannels.TryRemove(tp.Partition.Value, out var channel))
                    {
                        channel.Writer.Complete();
                    }
                }
            })
            .Build();

        consumer.Subscribe(topic);

        try
        {
            while (!cancellationToken.IsCancellationRequested)
            {
                var result = consumer.Consume(cancellationToken);

                if (_partitionChannels.TryGetValue(result.Partition.Value, out var channel))
                {
                    await channel.Writer.WriteAsync(result, cancellationToken);
                }
            }
        }
        finally
        {
            foreach (var channel in _partitionChannels.Values)
            {
                channel.Writer.Complete();
            }
            consumer.Close();
        }
    }

    private async Task ProcessPartitionAsync(
        int partition,
        ChannelReader<ConsumeResult<string, string>> reader,
        CancellationToken cancellationToken)
    {
        Console.WriteLine($"Started processor for partition {partition}");

        await foreach (var result in reader.ReadAllAsync(cancellationToken))
        {
            // Messages from same partition processed in order
            Console.WriteLine($"P{partition}: Processing {result.Message.Key}");
            await Task.Delay(50); // Simulate work
        }
    }
}
```

---

## 20. How do you implement schema evolution with Avro and Schema Registry?

**Answer:**

```csharp
using Confluent.Kafka;
using Confluent.SchemaRegistry;
using Confluent.SchemaRegistry.Serdes;
using Avro;
using Avro.Specific;

// Define Avro schema classes
// Version 1: Original schema
[Avro.Specific.AvroGenerated]
public partial class UserEventV1 : ISpecificRecord
{
    public static Schema _SCHEMA = Schema.Parse(@"{
        ""type"": ""record"",
        ""name"": ""UserEvent"",
        ""namespace"": ""com.example.events"",
        ""fields"": [
            { ""name"": ""userId"", ""type"": ""string"" },
            { ""name"": ""email"", ""type"": ""string"" },
            { ""name"": ""timestamp"", ""type"": ""long"" }
        ]
    }");

    public string UserId { get; set; }
    public string Email { get; set; }
    public long Timestamp { get; set; }

    public Schema Schema => _SCHEMA;

    public object Get(int fieldPos)
    {
        return fieldPos switch
        {
            0 => UserId,
            1 => Email,
            2 => Timestamp,
            _ => throw new AvroRuntimeException("Bad index")
        };
    }

    public void Put(int fieldPos, object fieldValue)
    {
        switch (fieldPos)
        {
            case 0: UserId = (string)fieldValue; break;
            case 1: Email = (string)fieldValue; break;
            case 2: Timestamp = (long)fieldValue; break;
            default: throw new AvroRuntimeException("Bad index");
        }
    }
}

// Version 2: Evolved schema with new optional field
[Avro.Specific.AvroGenerated]
public partial class UserEventV2 : ISpecificRecord
{
    public static Schema _SCHEMA = Schema.Parse(@"{
        ""type"": ""record"",
        ""name"": ""UserEvent"",
        ""namespace"": ""com.example.events"",
        ""fields"": [
            { ""name"": ""userId"", ""type"": ""string"" },
            { ""name"": ""email"", ""type"": ""string"" },
            { ""name"": ""timestamp"", ""type"": ""long"" },
            { ""name"": ""firstName"", ""type"": [""null"", ""string""], ""default"": null },
            { ""name"": ""lastName"", ""type"": [""null"", ""string""], ""default"": null }
        ]
    }");

    public string UserId { get; set; }
    public string Email { get; set; }
    public long Timestamp { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }

    public Schema Schema => _SCHEMA;
    // ... Get and Put implementations
}

public class SchemaRegistryExample
{
    private readonly ISchemaRegistryClient _schemaRegistry;
    private readonly string _bootstrapServers;

    public SchemaRegistryExample(string bootstrapServers, string schemaRegistryUrl)
    {
        _bootstrapServers = bootstrapServers;

        var schemaRegistryConfig = new SchemaRegistryConfig
        {
            Url = schemaRegistryUrl
        };

        _schemaRegistry = new CachedSchemaRegistryClient(schemaRegistryConfig);
    }

    // Producer with Avro serialization
    public async Task ProduceAvroMessage()
    {
        var producerConfig = new ProducerConfig { BootstrapServers = _bootstrapServers };

        using var producer = new ProducerBuilder<string, UserEventV2>(producerConfig)
            .SetValueSerializer(new AvroSerializer<UserEventV2>(_schemaRegistry))
            .Build();

        var userEvent = new UserEventV2
        {
            UserId = "user-123",
            Email = "user@example.com",
            Timestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(),
            FirstName = "John",
            LastName = "Doe"
        };

        await producer.ProduceAsync("user-events", new Message<string, UserEventV2>
        {
            Key = userEvent.UserId,
            Value = userEvent
        });
    }

    // Consumer that can read both V1 and V2 schemas
    public void ConsumeAvroMessages(CancellationToken cancellationToken)
    {
        var consumerConfig = new ConsumerConfig
        {
            BootstrapServers = _bootstrapServers,
            GroupId = "avro-consumer-group"
        };

        using var consumer = new ConsumerBuilder<string, UserEventV2>(consumerConfig)
            .SetValueDeserializer(new AvroDeserializer<UserEventV2>(_schemaRegistry).AsSyncOverAsync())
            .Build();

        consumer.Subscribe("user-events");

        while (!cancellationToken.IsCancellationRequested)
        {
            var result = consumer.Consume(cancellationToken);

            // V1 messages will have null FirstName/LastName
            var user = result.Message.Value;
            Console.WriteLine($"User: {user.UserId}, Name: {user.FirstName ?? "N/A"} {user.LastName ?? "N/A"}");
        }
    }

    // Register and manage schemas
    public async Task ManageSchemas()
    {
        var subject = "user-events-value";

        // Register a new schema
        var schemaId = await _schemaRegistry.RegisterSchemaAsync(subject, UserEventV2._SCHEMA.ToString());
        Console.WriteLine($"Registered schema with ID: {schemaId}");

        // Get latest schema
        var latestSchema = await _schemaRegistry.GetLatestSchemaAsync(subject);
        Console.WriteLine($"Latest schema version: {latestSchema.Version}");

        // Check compatibility before registering
        var isCompatible = await _schemaRegistry.IsCompatibleAsync(subject, UserEventV2._SCHEMA.ToString());
        Console.WriteLine($"Schema is compatible: {isCompatible}");

        // Get all versions
        var versions = await _schemaRegistry.GetSubjectVersionsAsync(subject);
        Console.WriteLine($"Schema versions: {string.Join(", ", versions)}");
    }
}
```

---

# Expert Level

## 21. How do you implement the Outbox Pattern with Kafka in .NET?

**Answer:**

The Outbox Pattern ensures atomicity between database changes and event publishing, preventing data inconsistencies.

```csharp
using Microsoft.EntityFrameworkCore;
using Confluent.Kafka;
using System.Text.Json;

// Outbox entity
public class OutboxMessage
{
    public Guid Id { get; set; }
    public string AggregateType { get; set; }
    public string AggregateId { get; set; }
    public string EventType { get; set; }
    public string Payload { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ProcessedAt { get; set; }
    public int RetryCount { get; set; }
    public string Error { get; set; }
}

// Domain entity
public class Order
{
    public Guid Id { get; set; }
    public string CustomerId { get; set; }
    public decimal TotalAmount { get; set; }
    public string Status { get; set; }
    public DateTime CreatedAt { get; set; }
}

// DbContext
public class ApplicationDbContext : DbContext
{
    public DbSet<Order> Orders { get; set; }
    public DbSet<OutboxMessage> OutboxMessages { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<OutboxMessage>(entity =>
        {
            entity.HasIndex(e => e.ProcessedAt)
                .HasFilter("[ProcessedAt] IS NULL");

            entity.Property(e => e.Payload)
                .HasColumnType("nvarchar(max)");
        });
    }
}

// Domain events
public interface IDomainEvent
{
    Guid EventId { get; }
    DateTime OccurredAt { get; }
}

public class OrderCreatedEvent : IDomainEvent
{
    public Guid EventId { get; set; } = Guid.NewGuid();
    public DateTime OccurredAt { get; set; } = DateTime.UtcNow;
    public Guid OrderId { get; set; }
    public string CustomerId { get; set; }
    public decimal TotalAmount { get; set; }
}

// Service that uses outbox
public class OrderService
{
    private readonly ApplicationDbContext _dbContext;

    public OrderService(ApplicationDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<Order> CreateOrderAsync(string customerId, decimal totalAmount)
    {
        // Use transaction to ensure atomicity
        await using var transaction = await _dbContext.Database.BeginTransactionAsync();

        try
        {
            // Create order
            var order = new Order
            {
                Id = Guid.NewGuid(),
                CustomerId = customerId,
                TotalAmount = totalAmount,
                Status = "Created",
                CreatedAt = DateTime.UtcNow
            };

            _dbContext.Orders.Add(order);

            // Create outbox message (same transaction)
            var domainEvent = new OrderCreatedEvent
            {
                OrderId = order.Id,
                CustomerId = customerId,
                TotalAmount = totalAmount
            };

            var outboxMessage = new OutboxMessage
            {
                Id = Guid.NewGuid(),
                AggregateType = nameof(Order),
                AggregateId = order.Id.ToString(),
                EventType = nameof(OrderCreatedEvent),
                Payload = JsonSerializer.Serialize(domainEvent),
                CreatedAt = DateTime.UtcNow
            };

            _dbContext.OutboxMessages.Add(outboxMessage);

            await _dbContext.SaveChangesAsync();
            await transaction.CommitAsync();

            return order;
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }
}

// Outbox processor (background service)
public class OutboxProcessor : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<OutboxProcessor> _logger;
    private readonly IProducer<string, string> _producer;

    public OutboxProcessor(
        IServiceProvider serviceProvider,
        ILogger<OutboxProcessor> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;

        var config = new ProducerConfig
        {
            BootstrapServers = "localhost:9092",
            EnableIdempotence = true,
            Acks = Acks.All
        };

        _producer = new ProducerBuilder<string, string>(config).Build();
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessOutboxMessagesAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing outbox messages");
            }

            await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
        }
    }

    private async Task ProcessOutboxMessagesAsync(CancellationToken cancellationToken)
    {
        using var scope = _serviceProvider.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        // Get unprocessed messages
        var messages = await dbContext.OutboxMessages
            .Where(m => m.ProcessedAt == null && m.RetryCount < 5)
            .OrderBy(m => m.CreatedAt)
            .Take(100)
            .ToListAsync(cancellationToken);

        foreach (var message in messages)
        {
            try
            {
                // Determine topic based on event type
                var topic = GetTopicForEventType(message.EventType);

                // Publish to Kafka
                var result = await _producer.ProduceAsync(topic, new Message<string, string>
                {
                    Key = message.AggregateId,
                    Value = message.Payload,
                    Headers = new Headers
                    {
                        { "event-type", Encoding.UTF8.GetBytes(message.EventType) },
                        { "aggregate-type", Encoding.UTF8.GetBytes(message.AggregateType) },
                        { "event-id", Encoding.UTF8.GetBytes(message.Id.ToString()) }
                    }
                }, cancellationToken);

                // Mark as processed
                message.ProcessedAt = DateTime.UtcNow;

                _logger.LogInformation(
                    "Published outbox message {MessageId} to {TopicPartitionOffset}",
                    message.Id, result.TopicPartitionOffset);
            }
            catch (Exception ex)
            {
                message.RetryCount++;
                message.Error = ex.Message;

                _logger.LogWarning(ex,
                    "Failed to publish outbox message {MessageId}, retry {RetryCount}",
                    message.Id, message.RetryCount);
            }
        }

        await dbContext.SaveChangesAsync(cancellationToken);
    }

    private string GetTopicForEventType(string eventType)
    {
        return eventType switch
        {
            nameof(OrderCreatedEvent) => "order-events",
            _ => "domain-events"
        };
    }

    public override void Dispose()
    {
        _producer?.Dispose();
        base.Dispose();
    }
}
```

---

## 22. How do you implement CQRS with Kafka event sourcing?

**Answer:**

```csharp
using Confluent.Kafka;
using System.Text.Json;

// Events
public abstract class DomainEvent
{
    public Guid EventId { get; set; } = Guid.NewGuid();
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    public string AggregateId { get; set; }
    public int Version { get; set; }
}

public class AccountCreatedEvent : DomainEvent
{
    public string AccountHolder { get; set; }
    public string Currency { get; set; }
}

public class MoneyDepositedEvent : DomainEvent
{
    public decimal Amount { get; set; }
    public string Description { get; set; }
}

public class MoneyWithdrawnEvent : DomainEvent
{
    public decimal Amount { get; set; }
    public string Description { get; set; }
}

// Aggregate
public class BankAccount
{
    public string Id { get; private set; }
    public string AccountHolder { get; private set; }
    public decimal Balance { get; private set; }
    public string Currency { get; private set; }
    public int Version { get; private set; }

    private readonly List<DomainEvent> _uncommittedEvents = new();

    public BankAccount() { }

    public BankAccount(string id, string accountHolder, string currency)
    {
        Apply(new AccountCreatedEvent
        {
            AggregateId = id,
            AccountHolder = accountHolder,
            Currency = currency
        });
    }

    public void Deposit(decimal amount, string description)
    {
        if (amount <= 0)
            throw new InvalidOperationException("Deposit amount must be positive");

        Apply(new MoneyDepositedEvent
        {
            AggregateId = Id,
            Amount = amount,
            Description = description
        });
    }

    public void Withdraw(decimal amount, string description)
    {
        if (amount <= 0)
            throw new InvalidOperationException("Withdrawal amount must be positive");

        if (Balance < amount)
            throw new InvalidOperationException("Insufficient funds");

        Apply(new MoneyWithdrawnEvent
        {
            AggregateId = Id,
            Amount = amount,
            Description = description
        });
    }

    private void Apply(DomainEvent @event)
    {
        @event.Version = Version + 1;
        When(@event);
        Version = @event.Version;
        _uncommittedEvents.Add(@event);
    }

    public void When(DomainEvent @event)
    {
        switch (@event)
        {
            case AccountCreatedEvent e:
                Id = e.AggregateId;
                AccountHolder = e.AccountHolder;
                Currency = e.Currency;
                Balance = 0;
                break;
            case MoneyDepositedEvent e:
                Balance += e.Amount;
                break;
            case MoneyWithdrawnEvent e:
                Balance -= e.Amount;
                break;
        }
    }

    public IReadOnlyList<DomainEvent> GetUncommittedEvents() => _uncommittedEvents.AsReadOnly();
    public void ClearUncommittedEvents() => _uncommittedEvents.Clear();

    public static BankAccount LoadFromHistory(IEnumerable<DomainEvent> history)
    {
        var account = new BankAccount();
        foreach (var @event in history)
        {
            account.When(@event);
            account.Version = @event.Version;
        }
        return account;
    }
}

// Event Store using Kafka
public class KafkaEventStore
{
    private readonly IProducer<string, string> _producer;
    private readonly ConsumerConfig _consumerConfig;
    private readonly string _eventsTopic;

    public KafkaEventStore(string bootstrapServers, string eventsTopic)
    {
        _eventsTopic = eventsTopic;

        var producerConfig = new ProducerConfig
        {
            BootstrapServers = bootstrapServers,
            EnableIdempotence = true,
            Acks = Acks.All
        };

        _producer = new ProducerBuilder<string, string>(producerConfig).Build();

        _consumerConfig = new ConsumerConfig
        {
            BootstrapServers = bootstrapServers,
            GroupId = $"event-store-reader-{Guid.NewGuid()}",
            AutoOffsetReset = AutoOffsetReset.Earliest,
            EnableAutoCommit = false
        };
    }

    public async Task AppendEventsAsync(string aggregateId, IEnumerable<DomainEvent> events)
    {
        foreach (var @event in events)
        {
            var eventData = new
            {
                EventType = @event.GetType().Name,
                Data = @event
            };

            await _producer.ProduceAsync(_eventsTopic, new Message<string, string>
            {
                Key = aggregateId,
                Value = JsonSerializer.Serialize(eventData),
                Headers = new Headers
                {
                    { "event-type", Encoding.UTF8.GetBytes(@event.GetType().Name) },
                    { "version", Encoding.UTF8.GetBytes(@event.Version.ToString()) }
                }
            });
        }
    }

    public async Task<List<DomainEvent>> GetEventsAsync(string aggregateId)
    {
        var events = new List<DomainEvent>();

        using var consumer = new ConsumerBuilder<string, string>(_consumerConfig).Build();
        consumer.Subscribe(_eventsTopic);

        // Read all events for this aggregate
        var timeout = TimeSpan.FromSeconds(5);
        var startTime = DateTime.UtcNow;

        while (DateTime.UtcNow - startTime < timeout)
        {
            var result = consumer.Consume(TimeSpan.FromMilliseconds(100));
            if (result == null) continue;

            if (result.Message.Key == aggregateId)
            {
                var eventType = Encoding.UTF8.GetString(
                    result.Message.Headers.First(h => h.Key == "event-type").GetValueBytes());

                var @event = DeserializeEvent(eventType, result.Message.Value);
                if (@event != null)
                {
                    events.Add(@event);
                }
            }
        }

        return events.OrderBy(e => e.Version).ToList();
    }

    private DomainEvent DeserializeEvent(string eventType, string json)
    {
        var document = JsonDocument.Parse(json);
        var data = document.RootElement.GetProperty("Data");

        return eventType switch
        {
            nameof(AccountCreatedEvent) => JsonSerializer.Deserialize<AccountCreatedEvent>(data.GetRawText()),
            nameof(MoneyDepositedEvent) => JsonSerializer.Deserialize<MoneyDepositedEvent>(data.GetRawText()),
            nameof(MoneyWithdrawnEvent) => JsonSerializer.Deserialize<MoneyWithdrawnEvent>(data.GetRawText()),
            _ => null
        };
    }
}

// Command Handler
public class BankAccountCommandHandler
{
    private readonly KafkaEventStore _eventStore;

    public BankAccountCommandHandler(KafkaEventStore eventStore)
    {
        _eventStore = eventStore;
    }

    public async Task<BankAccount> CreateAccountAsync(string accountHolder, string currency)
    {
        var accountId = Guid.NewGuid().ToString();
        var account = new BankAccount(accountId, accountHolder, currency);

        await _eventStore.AppendEventsAsync(accountId, account.GetUncommittedEvents());
        account.ClearUncommittedEvents();

        return account;
    }

    public async Task DepositAsync(string accountId, decimal amount, string description)
    {
        var events = await _eventStore.GetEventsAsync(accountId);
        var account = BankAccount.LoadFromHistory(events);

        account.Deposit(amount, description);

        await _eventStore.AppendEventsAsync(accountId, account.GetUncommittedEvents());
    }
}

// Read Model Projector
public class AccountBalanceProjector : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ConsumerConfig _consumerConfig;

    public AccountBalanceProjector(IServiceProvider serviceProvider, string bootstrapServers)
    {
        _serviceProvider = serviceProvider;
        _consumerConfig = new ConsumerConfig
        {
            BootstrapServers = bootstrapServers,
            GroupId = "account-balance-projector",
            AutoOffsetReset = AutoOffsetReset.Earliest
        };
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var consumer = new ConsumerBuilder<string, string>(_consumerConfig).Build();
        consumer.Subscribe("account-events");

        while (!stoppingToken.IsCancellationRequested)
        {
            var result = consumer.Consume(stoppingToken);
            await ProjectEventAsync(result);
            consumer.Commit(result);
        }
    }

    private async Task ProjectEventAsync(ConsumeResult<string, string> result)
    {
        using var scope = _serviceProvider.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<ReadModelDbContext>();

        var eventType = Encoding.UTF8.GetString(
            result.Message.Headers.First(h => h.Key == "event-type").GetValueBytes());

        // Update read model based on event type
        switch (eventType)
        {
            case nameof(AccountCreatedEvent):
                var created = JsonSerializer.Deserialize<AccountCreatedEvent>(
                    JsonDocument.Parse(result.Message.Value).RootElement.GetProperty("Data").GetRawText());
                dbContext.AccountBalances.Add(new AccountBalanceReadModel
                {
                    AccountId = created.AggregateId,
                    AccountHolder = created.AccountHolder,
                    Balance = 0,
                    Currency = created.Currency,
                    LastUpdated = created.Timestamp
                });
                break;

            case nameof(MoneyDepositedEvent):
                var deposited = JsonSerializer.Deserialize<MoneyDepositedEvent>(
                    JsonDocument.Parse(result.Message.Value).RootElement.GetProperty("Data").GetRawText());
                var accountDeposit = await dbContext.AccountBalances
                    .FindAsync(deposited.AggregateId);
                if (accountDeposit != null)
                {
                    accountDeposit.Balance += deposited.Amount;
                    accountDeposit.LastUpdated = deposited.Timestamp;
                }
                break;

            case nameof(MoneyWithdrawnEvent):
                var withdrawn = JsonSerializer.Deserialize<MoneyWithdrawnEvent>(
                    JsonDocument.Parse(result.Message.Value).RootElement.GetProperty("Data").GetRawText());
                var accountWithdraw = await dbContext.AccountBalances
                    .FindAsync(withdrawn.AggregateId);
                if (accountWithdraw != null)
                {
                    accountWithdraw.Balance -= withdrawn.Amount;
                    accountWithdraw.LastUpdated = withdrawn.Timestamp;
                }
                break;
        }

        await dbContext.SaveChangesAsync();
    }
}

public class AccountBalanceReadModel
{
    public string AccountId { get; set; }
    public string AccountHolder { get; set; }
    public decimal Balance { get; set; }
    public string Currency { get; set; }
    public DateTime LastUpdated { get; set; }
}
```

---

## 23. How do you implement Kafka Streams-like processing in .NET?

**Answer:**

While Kafka Streams is Java-native, you can implement similar stateful stream processing patterns in .NET.

```csharp
using Confluent.Kafka;
using System.Collections.Concurrent;

// Stream processor abstraction
public interface IStreamProcessor<TKey, TValue>
{
    Task ProcessAsync(TKey key, TValue value, IMessageContext context);
}

public interface IMessageContext
{
    string Topic { get; }
    int Partition { get; }
    long Offset { get; }
    DateTime Timestamp { get; }
    Headers Headers { get; }
    Task ForwardAsync<TK, TV>(string topic, TK key, TV value);
}

// Windowed aggregation
public class WindowedAggregator<TKey, TValue, TAgg>
{
    private readonly ConcurrentDictionary<(TKey, long), TAgg> _windows = new();
    private readonly TimeSpan _windowSize;
    private readonly Func<TAgg> _initializer;
    private readonly Func<TAgg, TValue, TAgg> _aggregator;

    public WindowedAggregator(
        TimeSpan windowSize,
        Func<TAgg> initializer,
        Func<TAgg, TValue, TAgg> aggregator)
    {
        _windowSize = windowSize;
        _initializer = initializer;
        _aggregator = aggregator;
    }

    public TAgg Aggregate(TKey key, TValue value, DateTime timestamp)
    {
        var windowStart = GetWindowStart(timestamp);
        var windowKey = (key, windowStart);

        return _windows.AddOrUpdate(
            windowKey,
            _ => _aggregator(_initializer(), value),
            (_, existing) => _aggregator(existing, value)
        );
    }

    private long GetWindowStart(DateTime timestamp)
    {
        var ticks = timestamp.Ticks;
        var windowTicks = _windowSize.Ticks;
        return ticks - (ticks % windowTicks);
    }

    public IEnumerable<((TKey Key, long WindowStart), TAgg Value)> GetExpiredWindows(DateTime currentTime)
    {
        var cutoff = GetWindowStart(currentTime - _windowSize - _windowSize);

        return _windows
            .Where(kv => kv.Key.Item2 < cutoff)
            .Select(kv => (kv.Key, kv.Value))
            .ToList();
    }

    public void RemoveWindow(TKey key, long windowStart)
    {
        _windows.TryRemove((key, windowStart), out _);
    }
}

// Example: Real-time metrics aggregation
public class MetricsAggregationProcessor
{
    private readonly ConsumerConfig _consumerConfig;
    private readonly ProducerConfig _producerConfig;
    private readonly WindowedAggregator<string, MetricEvent, MetricAggregate> _aggregator;

    public MetricsAggregationProcessor(string bootstrapServers)
    {
        _consumerConfig = new ConsumerConfig
        {
            BootstrapServers = bootstrapServers,
            GroupId = "metrics-aggregator",
            EnableAutoCommit = false
        };

        _producerConfig = new ProducerConfig
        {
            BootstrapServers = bootstrapServers,
            EnableIdempotence = true
        };

        _aggregator = new WindowedAggregator<string, MetricEvent, MetricAggregate>(
            windowSize: TimeSpan.FromMinutes(1),
            initializer: () => new MetricAggregate(),
            aggregator: (agg, evt) =>
            {
                agg.Count++;
                agg.Sum += evt.Value;
                agg.Min = Math.Min(agg.Min, evt.Value);
                agg.Max = Math.Max(agg.Max, evt.Value);
                return agg;
            }
        );
    }

    public async Task ProcessAsync(CancellationToken cancellationToken)
    {
        using var consumer = new ConsumerBuilder<string, string>(_consumerConfig).Build();
        using var producer = new ProducerBuilder<string, string>(_producerConfig).Build();

        consumer.Subscribe("raw-metrics");

        var punctuateTimer = new PeriodicTimer(TimeSpan.FromSeconds(10));
        var punctuateTask = PunctuateAsync(producer, punctuateTimer, cancellationToken);

        try
        {
            while (!cancellationToken.IsCancellationRequested)
            {
                var result = consumer.Consume(cancellationToken);

                var metric = JsonSerializer.Deserialize<MetricEvent>(result.Message.Value);

                // Aggregate
                var aggregate = _aggregator.Aggregate(
                    metric.MetricName,
                    metric,
                    result.Message.Timestamp.UtcDateTime);

                // Optionally emit intermediate results
                Console.WriteLine($"Current aggregate for {metric.MetricName}: " +
                    $"Count={aggregate.Count}, Avg={aggregate.Average:F2}");

                consumer.Commit(result);
            }
        }
        finally
        {
            punctuateTimer.Dispose();
            await punctuateTask;
        }
    }

    private async Task PunctuateAsync(
        IProducer<string, string> producer,
        PeriodicTimer timer,
        CancellationToken cancellationToken)
    {
        while (await timer.WaitForNextTickAsync(cancellationToken))
        {
            var now = DateTime.UtcNow;
            var expiredWindows = _aggregator.GetExpiredWindows(now);

            foreach (var ((metricName, windowStart), aggregate) in expiredWindows)
            {
                var windowResult = new
                {
                    MetricName = metricName,
                    WindowStart = new DateTime(windowStart),
                    WindowEnd = new DateTime(windowStart).AddMinutes(1),
                    Count = aggregate.Count,
                    Sum = aggregate.Sum,
                    Average = aggregate.Average,
                    Min = aggregate.Min,
                    Max = aggregate.Max
                };

                await producer.ProduceAsync("aggregated-metrics", new Message<string, string>
                {
                    Key = metricName,
                    Value = JsonSerializer.Serialize(windowResult)
                });

                _aggregator.RemoveWindow(metricName, windowStart);

                Console.WriteLine($"Emitted window result for {metricName}: {JsonSerializer.Serialize(windowResult)}");
            }
        }
    }
}

public class MetricEvent
{
    public string MetricName { get; set; }
    public double Value { get; set; }
    public DateTime Timestamp { get; set; }
    public Dictionary<string, string> Tags { get; set; }
}

public class MetricAggregate
{
    public int Count { get; set; }
    public double Sum { get; set; }
    public double Min { get; set; } = double.MaxValue;
    public double Max { get; set; } = double.MinValue;
    public double Average => Count > 0 ? Sum / Count : 0;
}

// Join processor (stream-stream join)
public class StreamJoinProcessor<TKey, TLeft, TRight, TResult>
{
    private readonly ConcurrentDictionary<TKey, List<(TLeft Value, DateTime Timestamp)>> _leftBuffer = new();
    private readonly ConcurrentDictionary<TKey, List<(TRight Value, DateTime Timestamp)>> _rightBuffer = new();
    private readonly TimeSpan _joinWindow;
    private readonly Func<TLeft, TRight, TResult> _joiner;

    public StreamJoinProcessor(TimeSpan joinWindow, Func<TLeft, TRight, TResult> joiner)
    {
        _joinWindow = joinWindow;
        _joiner = joiner;
    }

    public IEnumerable<TResult> ProcessLeft(TKey key, TLeft value, DateTime timestamp)
    {
        // Add to left buffer
        var leftList = _leftBuffer.GetOrAdd(key, _ => new List<(TLeft, DateTime)>());
        lock (leftList)
        {
            leftList.Add((value, timestamp));
            CleanExpired(leftList, timestamp);
        }

        // Join with right buffer
        if (_rightBuffer.TryGetValue(key, out var rightList))
        {
            lock (rightList)
            {
                foreach (var (rightValue, rightTimestamp) in rightList)
                {
                    if (Math.Abs((timestamp - rightTimestamp).TotalMilliseconds) <= _joinWindow.TotalMilliseconds)
                    {
                        yield return _joiner(value, rightValue);
                    }
                }
            }
        }
    }

    public IEnumerable<TResult> ProcessRight(TKey key, TRight value, DateTime timestamp)
    {
        // Add to right buffer
        var rightList = _rightBuffer.GetOrAdd(key, _ => new List<(TRight, DateTime)>());
        lock (rightList)
        {
            rightList.Add((value, timestamp));
            CleanExpired(rightList, timestamp);
        }

        // Join with left buffer
        if (_leftBuffer.TryGetValue(key, out var leftList))
        {
            lock (leftList)
            {
                foreach (var (leftValue, leftTimestamp) in leftList)
                {
                    if (Math.Abs((timestamp - leftTimestamp).TotalMilliseconds) <= _joinWindow.TotalMilliseconds)
                    {
                        yield return _joiner(leftValue, value);
                    }
                }
            }
        }
    }

    private void CleanExpired<T>(List<(T Value, DateTime Timestamp)> list, DateTime currentTime)
    {
        list.RemoveAll(item => currentTime - item.Timestamp > _joinWindow * 2);
    }
}
```

---

## 24. How do you handle backpressure in Kafka consumers?

**Answer:**

```csharp
using Confluent.Kafka;
using System.Threading.Channels;

public class BackpressureAwareConsumer
{
    private readonly ConsumerConfig _consumerConfig;
    private readonly int _maxBufferSize;
    private readonly int _pauseThreshold;
    private readonly int _resumeThreshold;

    public BackpressureAwareConsumer(
        string bootstrapServers,
        string groupId,
        int maxBufferSize = 10000,
        int pauseThreshold = 8000,
        int resumeThreshold = 2000)
    {
        _maxBufferSize = maxBufferSize;
        _pauseThreshold = pauseThreshold;
        _resumeThreshold = resumeThreshold;

        _consumerConfig = new ConsumerConfig
        {
            BootstrapServers = bootstrapServers,
            GroupId = groupId,
            EnableAutoCommit = false,
            MaxPollIntervalMs = 300000,
            // Limit records per poll for better control
            MaxPartitionFetchBytes = 1048576, // 1MB
            FetchMaxBytes = 52428800 // 50MB
        };
    }

    public async Task ConsumeWithBackpressure(
        string topic,
        Func<ConsumeResult<string, string>, Task> processor,
        CancellationToken cancellationToken)
    {
        var channel = Channel.CreateBounded<ConsumeResult<string, string>>(
            new BoundedChannelOptions(_maxBufferSize)
            {
                FullMode = BoundedChannelFullMode.Wait,
                SingleReader = false,
                SingleWriter = true
            });

        using var consumer = new ConsumerBuilder<string, string>(_consumerConfig).Build();
        consumer.Subscribe(topic);

        var isPaused = false;
        var pausedPartitions = new List<TopicPartition>();

        // Producer task (reads from Kafka)
        var producerTask = Task.Run(async () =>
        {
            try
            {
                while (!cancellationToken.IsCancellationRequested)
                {
                    // Check buffer level
                    var bufferCount = channel.Reader.Count;

                    if (!isPaused && bufferCount >= _pauseThreshold)
                    {
                        // Pause consumption
                        pausedPartitions = consumer.Assignment.ToList();
                        consumer.Pause(pausedPartitions);
                        isPaused = true;
                        Console.WriteLine($"Paused consumption at buffer level {bufferCount}");
                    }
                    else if (isPaused && bufferCount <= _resumeThreshold)
                    {
                        // Resume consumption
                        consumer.Resume(pausedPartitions);
                        isPaused = false;
                        Console.WriteLine($"Resumed consumption at buffer level {bufferCount}");
                    }

                    if (!isPaused)
                    {
                        var result = consumer.Consume(TimeSpan.FromMilliseconds(100));
                        if (result != null)
                        {
                            await channel.Writer.WriteAsync(result, cancellationToken);
                        }
                    }
                    else
                    {
                        await Task.Delay(100, cancellationToken);
                    }
                }
            }
            finally
            {
                channel.Writer.Complete();
            }
        }, cancellationToken);

        // Consumer tasks (process messages)
        var consumerTasks = Enumerable.Range(0, Environment.ProcessorCount)
            .Select(_ => Task.Run(async () =>
            {
                await foreach (var result in channel.Reader.ReadAllAsync(cancellationToken))
                {
                    try
                    {
                        await processor(result);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Processing error: {ex.Message}");
                    }
                }
            }, cancellationToken))
            .ToList();

        await Task.WhenAll(consumerTasks.Append(producerTask));
    }
}

// Rate-limited consumer
public class RateLimitedConsumer
{
    private readonly SemaphoreSlim _rateLimiter;
    private readonly ConsumerConfig _consumerConfig;

    public RateLimitedConsumer(
        string bootstrapServers,
        string groupId,
        int maxMessagesPerSecond)
    {
        _rateLimiter = new SemaphoreSlim(maxMessagesPerSecond, maxMessagesPerSecond);

        _consumerConfig = new ConsumerConfig
        {
            BootstrapServers = bootstrapServers,
            GroupId = groupId,
            EnableAutoCommit = false
        };

        // Replenish rate limiter every second
        _ = ReplenishRateLimiter(maxMessagesPerSecond);
    }

    private async Task ReplenishRateLimiter(int maxPerSecond)
    {
        var timer = new PeriodicTimer(TimeSpan.FromSeconds(1));
        while (await timer.WaitForNextTickAsync())
        {
            var currentCount = _rateLimiter.CurrentCount;
            var toRelease = maxPerSecond - currentCount;
            if (toRelease > 0)
            {
                _rateLimiter.Release(toRelease);
            }
        }
    }

    public async Task ConsumeRateLimited(
        string topic,
        Func<ConsumeResult<string, string>, Task> processor,
        CancellationToken cancellationToken)
    {
        using var consumer = new ConsumerBuilder<string, string>(_consumerConfig).Build();
        consumer.Subscribe(topic);

        while (!cancellationToken.IsCancellationRequested)
        {
            await _rateLimiter.WaitAsync(cancellationToken);

            var result = consumer.Consume(cancellationToken);

            try
            {
                await processor(result);
                consumer.Commit(result);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }
}
```

---

## 25. How do you implement high-availability Kafka consumers with graceful shutdown?

**Answer:**

```csharp
using Confluent.Kafka;
using Microsoft.Extensions.Hosting;

public class HighAvailabilityConsumer : BackgroundService
{
    private readonly ILogger<HighAvailabilityConsumer> _logger;
    private readonly IServiceProvider _serviceProvider;
    private readonly ConsumerConfig _consumerConfig;
    private readonly string _topic;
    private IConsumer<string, string> _consumer;
    private readonly ConcurrentDictionary<TopicPartition, long> _processingOffsets = new();
    private readonly SemaphoreSlim _shutdownSemaphore = new(1, 1);
    private volatile bool _isShuttingDown;

    public HighAvailabilityConsumer(
        ILogger<HighAvailabilityConsumer> logger,
        IServiceProvider serviceProvider,
        IConfiguration configuration)
    {
        _logger = logger;
        _serviceProvider = serviceProvider;
        _topic = configuration["Kafka:Topic"];

        _consumerConfig = new ConsumerConfig
        {
            BootstrapServers = configuration["Kafka:BootstrapServers"],
            GroupId = configuration["Kafka:GroupId"],
            EnableAutoCommit = false,
            AutoOffsetReset = AutoOffsetReset.Earliest,

            // High availability settings
            SessionTimeoutMs = 45000,
            HeartbeatIntervalMs = 15000,
            MaxPollIntervalMs = 300000,

            // Cooperative rebalancing for minimal disruption
            PartitionAssignmentStrategy = PartitionAssignmentStrategy.CooperativeSticky,

            // Isolation level for transactional reads
            IsolationLevel = IsolationLevel.ReadCommitted
        };
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await Task.Yield();

        _consumer = new ConsumerBuilder<string, string>(_consumerConfig)
            .SetPartitionsAssignedHandler((c, partitions) =>
            {
                _logger.LogInformation("Partitions assigned: {Partitions}",
                    string.Join(", ", partitions));
            })
            .SetPartitionsRevokedHandler((c, partitions) =>
            {
                _logger.LogInformation("Partitions being revoked: {Partitions}",
                    string.Join(", ", partitions));

                // Commit offsets for revoked partitions
                CommitProcessedOffsets(partitions);
            })
            .SetPartitionsLostHandler((c, partitions) =>
            {
                _logger.LogWarning("Partitions lost: {Partitions}",
                    string.Join(", ", partitions));

                // Clean up state for lost partitions
                foreach (var tp in partitions)
                {
                    _processingOffsets.TryRemove(tp, out _);
                }
            })
            .SetErrorHandler((_, error) =>
            {
                _logger.LogError("Consumer error: {Error}", error.Reason);

                if (error.IsFatal)
                {
                    _logger.LogCritical("Fatal error - consumer needs restart");
                }
            })
            .SetStatisticsHandler((_, stats) =>
            {
                // Log statistics for monitoring
                _logger.LogDebug("Statistics: {Stats}", stats);
            })
            .Build();

        _consumer.Subscribe(_topic);

        _logger.LogInformation("Consumer started for topic {Topic}", _topic);

        try
        {
            while (!stoppingToken.IsCancellationRequested && !_isShuttingDown)
            {
                try
                {
                    var result = _consumer.Consume(TimeSpan.FromMilliseconds(100));

                    if (result == null) continue;

                    await ProcessMessageAsync(result, stoppingToken);

                    // Track processed offset
                    _processingOffsets[result.TopicPartition] = result.Offset;

                    // Periodic commit
                    if (ShouldCommit())
                    {
                        CommitProcessedOffsets(_consumer.Assignment);
                    }
                }
                catch (ConsumeException ex)
                {
                    _logger.LogError(ex, "Consume error");

                    if (ex.Error.IsFatal)
                    {
                        throw;
                    }
                }
            }
        }
        catch (OperationCanceledException)
        {
            _logger.LogInformation("Consumer cancellation requested");
        }
        finally
        {
            await GracefulShutdownAsync();
        }
    }

    private async Task ProcessMessageAsync(
        ConsumeResult<string, string> result,
        CancellationToken cancellationToken)
    {
        using var scope = _serviceProvider.CreateScope();
        var handler = scope.ServiceProvider.GetRequiredService<IMessageHandler>();

        await handler.HandleAsync(result.Message.Key, result.Message.Value);
    }

    private bool ShouldCommit()
    {
        // Commit every 100 messages or use time-based
        return _processingOffsets.Values.Sum() % 100 == 0;
    }

    private void CommitProcessedOffsets(IEnumerable<TopicPartition> partitions)
    {
        var offsets = partitions
            .Where(tp => _processingOffsets.ContainsKey(tp))
            .Select(tp => new TopicPartitionOffset(tp, _processingOffsets[tp] + 1))
            .ToList();

        if (offsets.Any())
        {
            try
            {
                _consumer.Commit(offsets);
                _logger.LogDebug("Committed offsets: {Offsets}",
                    string.Join(", ", offsets));
            }
            catch (KafkaException ex)
            {
                _logger.LogError(ex, "Failed to commit offsets");
            }
        }
    }

    private async Task GracefulShutdownAsync()
    {
        await _shutdownSemaphore.WaitAsync();

        try
        {
            _isShuttingDown = true;
            _logger.LogInformation("Starting graceful shutdown");

            // Commit final offsets
            CommitProcessedOffsets(_consumer.Assignment);

            // Close consumer (triggers final rebalance)
            _consumer.Close();
            _consumer.Dispose();

            _logger.LogInformation("Consumer shut down gracefully");
        }
        finally
        {
            _shutdownSemaphore.Release();
        }
    }

    public override async Task StopAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("StopAsync called");
        _isShuttingDown = true;
        await base.StopAsync(cancellationToken);
    }
}

// Health check for Kafka consumer
public class KafkaConsumerHealthCheck : IHealthCheck
{
    private readonly IConsumer<string, string> _consumer;
    private readonly string _topic;

    public KafkaConsumerHealthCheck(IConsumer<string, string> consumer, string topic)
    {
        _consumer = consumer;
        _topic = topic;
    }

    public Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        try
        {
            // Check if consumer is assigned partitions
            var assignment = _consumer.Assignment;

            if (!assignment.Any())
            {
                return Task.FromResult(HealthCheckResult.Degraded(
                    "No partitions assigned"));
            }

            // Check lag
            var positions = assignment
                .Select(tp => (tp, _consumer.Position(tp)))
                .ToList();

            return Task.FromResult(HealthCheckResult.Healthy(
                $"Consumer healthy. Assigned partitions: {assignment.Count}"));
        }
        catch (Exception ex)
        {
            return Task.FromResult(HealthCheckResult.Unhealthy(
                "Consumer unhealthy", ex));
        }
    }
}
```

---

## Summary: Key Concepts Quick Reference

| Level | Topic | Key Points |
|-------|-------|------------|
| Beginner | Core Components | Producer, Consumer, Broker, Topic, Partition |
| Beginner | Consumer Groups | Load balancing, partition assignment |
| Beginner | Offset Management | Auto vs manual commit |
| Intermediate | Serialization | JSON, Avro, Schema Registry |
| Intermediate | Error Handling | Retries, idempotence, dead letter queues |
| Intermediate | Headers | Metadata, tracing, routing |
| Advanced | Exactly-Once | Transactions, idempotent producers |
| Advanced | Rebalancing | Handlers, cooperative sticky |
| Expert | Outbox Pattern | Database + Kafka atomicity |
| Expert | CQRS/Event Sourcing | Event store, projections |
| Expert | Stream Processing | Windowing, joins, aggregations |

---

## Additional Resources

- [Confluent .NET Client Documentation](https://docs.confluent.io/kafka-clients/dotnet/current/overview.html)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Confluent Schema Registry](https://docs.confluent.io/platform/current/schema-registry/)
- [Kafka Design Patterns](https://developer.confluent.io/patterns/)
