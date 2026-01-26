# Day 21: Real-Time Systems - SignalR, WebSockets & SSE

## Overview
Real-time communication is critical for modern applications (dashboards, notifications, chat, live updates). This guide covers SignalR, WebSockets, Server-Sent Events, and scaling strategies for Senior/SDE-2 interviews at companies like Microsoft, Meta, Slack, and trading platforms.

**Real Interview Context:**
- Microsoft: "Design a real-time collaboration feature like Microsoft Teams presence"
- Meta: "Build a scalable notification system for billions of users"
- Trading Platforms: "How do you push real-time stock prices to millions of clients?"
- Slack: "Design a chat system with typing indicators and message delivery confirmation"

---

## 1. Real-Time Communication Protocols

> **Key Real-Time Terminology Explained:**
>
> **WebSocket**: A persistent, bi-directional communication protocol that maintains an open connection between client and server. Unlike HTTP (request-response), WebSockets allow either side to send messages at any time without waiting for a request.
> - **Use case**: Chat, gaming, collaborative editing
> - **Pros**: Low latency, bi-directional, efficient
> - **Cons**: Stateful connections require more server resources
>
> **Server-Sent Events (SSE)**: A one-way communication channel from server to client over HTTP. The server can push updates to the client, but the client can only send requests via regular HTTP.
> - **Use case**: Live feeds, notifications, dashboards
> - **Pros**: Simple, works over HTTP, automatic reconnection
> - **Cons**: One-way only (server → client)
>
> **Long Polling**: A technique where the client makes an HTTP request, and the server holds the connection open until new data is available. Once data is sent, the client immediately makes another request.
> - **Use case**: Legacy fallback when WebSocket isn't available
> - **Cons**: High overhead from repeated connections
>
> **Backplane (Redis Backplane)**: When scaling SignalR across multiple servers, a backplane is a messaging infrastructure that synchronizes messages between all server instances. Without it, a message sent to Server A won't reach clients connected to Server B.
> ```
> Client1 ─────┐                    ┌───── Client3
>              │                    │
>          Server A   ←──Redis──→  Server B
>              │                    │
> Client2 ─────┘                    └───── Client4
> ```
> Messages published to Redis are broadcast to all servers, ensuring all clients receive updates.
>
> **TTL (Time To Live)**: The duration a piece of data remains valid before expiring. Used in caching and presence systems to automatically clean up stale data.

### Protocol Comparison Matrix

| Protocol | Direction | Use Case | Browser Support | Connection Overhead |
|----------|-----------|----------|-----------------|---------------------|
| **WebSocket** | Bi-directional | Chat, gaming, collaboration | All modern browsers | Low (persistent) |
| **Server-Sent Events (SSE)** | Server → Client | Notifications, live feeds | All modern browsers | Low (persistent) |
| **Long Polling** | Client pulls | Legacy fallback | All browsers | High (repeated requests) |
| **HTTP/2 Server Push** | Server → Client | Asset pre-loading | Modern browsers | Medium |
| **SignalR** | Bi-directional | .NET apps (abstracts protocol) | All browsers | Low (auto-selects protocol) |

### When to Use What

```
┌────────────────────────────────────────────────────────────────┐
│ Requirement            │ Best Protocol                         │
├────────────────────────────────────────────────────────────────┤
│ Chat, collaboration    │ WebSocket (bi-directional)            │
│ Live dashboards        │ SSE (server → client only)            │
│ Stock prices, sports   │ SSE or WebSocket                      │
│ Typing indicators      │ WebSocket (real-time, bi-directional) │
│ Notifications          │ SSE (one-way, simpler)                │
│ Gaming, real-time edit │ WebSocket (low latency)               │
│ File upload progress   │ SSE (server → client updates)         │
│ Legacy browser support │ Long Polling (fallback)               │
│ .NET Full Stack        │ SignalR (automatic fallback)          │
└────────────────────────────────────────────────────────────────┘
```

---

## 2. SignalR Core Architecture

### Hub-Based Communication

```csharp
// SignalR Hub - Server-side
public class ChatHub : Hub
{
    private readonly ILogger<ChatHub> _logger;
    private readonly IChatService _chatService;

    // Called when client connects
    public override async Task OnConnectedAsync()
    {
        var userId = Context.User?.FindFirstValue(ClaimTypes.NameIdentifier);
        var connectionId = Context.ConnectionId;

        _logger.LogInformation($"User {userId} connected: {connectionId}");

        // Add user to their personal group (for targeted messages)
        await Groups.AddToGroupAsync(connectionId, $"user:{userId}");

        // Notify others of user's online status
        await Clients.Others.SendAsync("UserConnected", userId);

        await base.OnConnectedAsync();
    }

    // Called when client disconnects
    public override async Task OnDisconnectedAsync(Exception exception)
    {
        var userId = Context.User?.FindFirstValue(ClaimTypes.NameIdentifier);
        _logger.LogInformation($"User {userId} disconnected");

        await Clients.Others.SendAsync("UserDisconnected", userId);

        await base.OnDisconnectedAsync(exception);
    }

    // Client → Server: Send message
    public async Task SendMessage(string roomId, string message)
    {
        var userId = Context.User?.FindFirstValue(ClaimTypes.NameIdentifier);
        var username = Context.User?.Identity?.Name;

        // Validate and sanitize
        if (string.IsNullOrWhiteSpace(message) || message.Length > 1000)
        {
            await Clients.Caller.SendAsync("Error", "Invalid message");
            return;
        }

        // Save to database
        var chatMessage = await _chatService.SaveMessageAsync(roomId, userId, message);

        // Broadcast to all users in room
        await Clients.Group(roomId).SendAsync("ReceiveMessage", new
        {
            chatMessage.Id,
            chatMessage.UserId,
            Username = username,
            Message = message,
            Timestamp = chatMessage.CreatedAt
        });
    }

    // Client → Server: Join chat room
    public async Task JoinRoom(string roomId)
    {
        var userId = Context.User?.FindFirstValue(ClaimTypes.NameIdentifier);
        var username = Context.User?.Identity?.Name;

        await Groups.AddToGroupAsync(Context.ConnectionId, roomId);

        _logger.LogInformation($"User {username} joined room {roomId}");

        // Notify room members
        await Clients.OthersInGroup(roomId).SendAsync("UserJoined", username);

        // Send recent message history to new user
        var recentMessages = await _chatService.GetRecentMessagesAsync(roomId, 50);
        await Clients.Caller.SendAsync("MessageHistory", recentMessages);
    }

    // Client → Server: Leave chat room
    public async Task LeaveRoom(string roomId)
    {
        var username = Context.User?.Identity?.Name;

        await Groups.RemoveFromGroupAsync(Context.ConnectionId, roomId);

        await Clients.Group(roomId).SendAsync("UserLeft", username);
    }

    // Client → Server: Typing indicator
    public async Task UserTyping(string roomId, bool isTyping)
    {
        var username = Context.User?.Identity?.Name;

        await Clients.OthersInGroup(roomId).SendAsync("UserTyping", username, isTyping);
    }
}

// ASP.NET Core Startup Configuration
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddSignalR(options =>
        {
            // Production settings
            options.EnableDetailedErrors = false; // Don't expose stack traces
            options.KeepAliveInterval = TimeSpan.FromSeconds(15);
            options.ClientTimeoutInterval = TimeSpan.FromSeconds(30);
            options.HandshakeTimeout = TimeSpan.FromSeconds(15);
            options.MaximumReceiveMessageSize = 32 * 1024; // 32KB max message

            // Performance tuning
            options.StreamBufferCapacity = 10; // Buffered streaming
        })
        .AddStackExchangeRedis(redisConnectionString, options =>
        {
            // Scale-out with Redis backplane
            options.Configuration.ChannelPrefix = "SignalR";
        });

        // Add authentication
        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                // Allow JWT in SignalR connection
                options.Events = new JwtBearerEvents
                {
                    OnMessageReceived = context =>
                    {
                        var accessToken = context.Request.Query["access_token"];

                        var path = context.HttpContext.Request.Path;
                        if (!string.IsNullOrEmpty(accessToken) &&
                            path.StartsWithSegments("/hubs"))
                        {
                            context.Token = accessToken;
                        }
                        return Task.CompletedTask;
                    }
                };
            });
    }

    public void Configure(IApplicationBuilder app)
    {
        app.UseRouting();
        app.UseAuthentication();
        app.UseAuthorization();

        app.UseEndpoints(endpoints =>
        {
            endpoints.MapHub<ChatHub>("/hubs/chat");
            endpoints.MapHub<NotificationHub>("/hubs/notifications");
        });
    }
}
```

### React/TypeScript Client

```typescript
// SignalR Client Setup
import { HubConnectionBuilder, HubConnection, LogLevel } from '@microsoft/signalr';

export class ChatClient {
    private connection: HubConnection;
    private reconnectAttempts = 0;
    private maxReconnectAttempts = 5;

    constructor(hubUrl: string, accessToken: string) {
        this.connection = new HubConnectionBuilder()
            .withUrl(hubUrl, {
                accessTokenFactory: () => accessToken
            })
            .withAutomaticReconnect({
                nextRetryDelayInMilliseconds: (retryContext) => {
                    // Exponential backoff: 0s, 2s, 10s, 30s, 60s
                    if (retryContext.previousRetryCount === 0) return 0;
                    if (retryContext.previousRetryCount === 1) return 2000;
                    if (retryContext.previousRetryCount === 2) return 10000;
                    if (retryContext.previousRetryCount === 3) return 30000;
                    return 60000;
                }
            })
            .configureLogging(LogLevel.Information)
            .build();

        // Connection lifecycle events
        this.connection.onclose((error) => {
            console.error('Connection closed:', error);
        });

        this.connection.onreconnecting((error) => {
            console.warn('Reconnecting:', error);
        });

        this.connection.onreconnected((connectionId) => {
            console.info('Reconnected:', connectionId);
            this.reconnectAttempts = 0;
        });
    }

    async start(): Promise<void> {
        try {
            await this.connection.start();
            console.info('SignalR Connected');
        } catch (error) {
            console.error('Connection failed:', error);
            this.handleReconnect();
        }
    }

    private async handleReconnect(): Promise<void> {
        if (this.reconnectAttempts >= this.maxReconnectAttempts) {
            console.error('Max reconnect attempts reached');
            return;
        }

        this.reconnectAttempts++;
        const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts), 30000);

        setTimeout(() => this.start(), delay);
    }

    // Subscribe to server events
    onReceiveMessage(callback: (message: ChatMessage) => void): void {
        this.connection.on('ReceiveMessage', callback);
    }

    onUserJoined(callback: (username: string) => void): void {
        this.connection.on('UserJoined', callback);
    }

    onUserLeft(callback: (username: string) => void): void {
        this.connection.on('UserLeft', callback);
    }

    onUserTyping(callback: (username: string, isTyping: boolean) => void): void {
        this.connection.on('UserTyping', callback);
    }

    // Invoke server methods
    async sendMessage(roomId: string, message: string): Promise<void> {
        try {
            await this.connection.invoke('SendMessage', roomId, message);
        } catch (error) {
            console.error('Send message failed:', error);
            throw error;
        }
    }

    async joinRoom(roomId: string): Promise<void> {
        await this.connection.invoke('JoinRoom', roomId);
    }

    async leaveRoom(roomId: string): Promise<void> {
        await this.connection.invoke('LeaveRoom', roomId);
    }

    async notifyTyping(roomId: string, isTyping: boolean): Promise<void> {
        await this.connection.invoke('UserTyping', roomId, isTyping);
    }

    async stop(): Promise<void> {
        await this.connection.stop();
    }
}

// React Hook
export const useChatRoom = (roomId: string) => {
    const [messages, setMessages] = useState<ChatMessage[]>([]);
    const [typingUsers, setTypingUsers] = useState<Set<string>>(new Set());
    const chatClientRef = useRef<ChatClient | null>(null);
    const typingTimeoutRef = useRef<NodeJS.Timeout | null>(null);

    useEffect(() => {
        const token = getAccessToken(); // From auth context
        const client = new ChatClient('/hubs/chat', token);

        // Subscribe to events
        client.onReceiveMessage((message) => {
            setMessages((prev) => [...prev, message]);
        });

        client.onUserJoined((username) => {
            console.log(`${username} joined`);
        });

        client.onUserTyping((username, isTyping) => {
            setTypingUsers((prev) => {
                const newSet = new Set(prev);
                if (isTyping) {
                    newSet.add(username);
                } else {
                    newSet.delete(username);
                }
                return newSet;
            });
        });

        // Connect and join room
        client.start().then(() => {
            client.joinRoom(roomId);
        });

        chatClientRef.current = client;

        return () => {
            client.leaveRoom(roomId);
            client.stop();
        };
    }, [roomId]);

    const sendMessage = async (message: string) => {
        await chatClientRef.current?.sendMessage(roomId, message);
    };

    const handleTyping = () => {
        if (typingTimeoutRef.current) {
            clearTimeout(typingTimeoutRef.current);
        }

        // Notify server user is typing
        chatClientRef.current?.notifyTyping(roomId, true);

        // Stop typing after 3 seconds of inactivity
        typingTimeoutRef.current = setTimeout(() => {
            chatClientRef.current?.notifyTyping(roomId, false);
        }, 3000);
    };

    return {
        messages,
        typingUsers: Array.from(typingUsers),
        sendMessage,
        handleTyping,
    };
};

// Usage in React Component
const ChatRoom: React.FC<{ roomId: string }> = ({ roomId }) => {
    const { messages, typingUsers, sendMessage, handleTyping } = useChatRoom(roomId);
    const [inputValue, setInputValue] = useState('');

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (inputValue.trim()) {
            await sendMessage(inputValue);
            setInputValue('');
        }
    };

    return (
        <div className="chat-room">
            <div className="messages">
                {messages.map((msg) => (
                    <div key={msg.id} className="message">
                        <strong>{msg.username}:</strong> {msg.message}
                    </div>
                ))}
            </div>

            {typingUsers.length > 0 && (
                <div className="typing-indicator">
                    {typingUsers.join(', ')} {typingUsers.length === 1 ? 'is' : 'are'} typing...
                </div>
            )}

            <form onSubmit={handleSubmit}>
                <input
                    value={inputValue}
                    onChange={(e) => {
                        setInputValue(e.target.value);
                        handleTyping();
                    }}
                    placeholder="Type a message..."
                />
                <button type="submit">Send</button>
            </form>
        </div>
    );
};
```

**Interview Talking Points:**
- "SignalR abstracts WebSocket, SSE, and long polling - automatically falls back"
- "Hub methods are strongly-typed - no string-based event names needed in .NET client"
- "Automatic reconnection with exponential backoff prevents thundering herd"
- "Groups enable targeted broadcasting (chat rooms, user-specific notifications)"

---

## 3. Scaling SignalR with Redis Backplane

### Single Server vs Scale-Out

```
Single Server (Works for < 1000 concurrent connections):
┌─────────────────────────────────┐
│   SignalR Server                │
│   ┌─────────────────────────┐   │
│   │ In-Memory Connection    │   │
│   │ Tracking                │   │
│   └─────────────────────────┘   │
│            ▲                     │
│            │                     │
└────────────┼─────────────────────┘
             │
    ┌────────┴────────┐
    │                 │
  Client1          Client2

Scale-Out (Required for > 1000 connections):
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│ Server 1     │         │ Server 2     │         │ Server 3     │
│ Client1      │         │ Client3      │         │ Client5      │
│ Client2      │         │ Client4      │         │ Client6      │
└──────┬───────┘         └──────┬───────┘         └──────┬───────┘
       │                        │                        │
       └────────────────────────┼────────────────────────┘
                                │
                         ┌──────▼──────┐
                         │ Redis       │
                         │ (Backplane) │
                         └─────────────┘

Message flow:
1. Client1 sends message to Server1
2. Server1 publishes to Redis
3. Redis broadcasts to all servers
4. Server2 and Server3 push to their clients
```

### Redis Backplane Configuration

```csharp
// Startup.cs
public void ConfigureServices(IServiceCollection services)
{
    services.AddSignalR()
        .AddStackExchangeRedis(options =>
        {
            options.Configuration = ConfigurationOptions.Parse(
                Configuration["Redis:ConnectionString"]);

            // Channel prefix to isolate SignalR messages
            options.Configuration.ChannelPrefix = "SignalR";

            // Performance tuning
            options.Configuration.AbortOnConnectFail = false;
            options.Configuration.ConnectTimeout = 5000;
            options.Configuration.SyncTimeout = 5000;
            options.Configuration.KeepAlive = 60;
            options.Configuration.ConnectRetry = 3;
        });

    // Connection tracking for presence/online status
    services.AddSingleton<IConnectionTracker, RedisConnectionTracker>();
}

// Track online users across servers
public class RedisConnectionTracker : IConnectionTracker
{
    private readonly IConnectionMultiplexer _redis;
    private readonly IDatabase _db;

    public RedisConnectionTracker(IConnectionMultiplexer redis)
    {
        _redis = redis;
        _db = redis.GetDatabase();
    }

    public async Task AddConnectionAsync(string userId, string connectionId)
    {
        // Store in sorted set with timestamp
        await _db.SortedSetAddAsync(
            $"user:connections:{userId}",
            connectionId,
            DateTimeOffset.UtcNow.ToUnixTimeSeconds());

        // Set expiration
        await _db.KeyExpireAsync(
            $"user:connections:{userId}",
            TimeSpan.FromHours(24));
    }

    public async Task RemoveConnectionAsync(string userId, string connectionId)
    {
        await _db.SortedSetRemoveAsync(
            $"user:connections:{userId}",
            connectionId);
    }

    public async Task<bool> IsUserOnlineAsync(string userId)
    {
        var count = await _db.SortedSetLengthAsync($"user:connections:{userId}");
        return count > 0;
    }

    public async Task<List<string>> GetOnlineUsersAsync()
    {
        // Scan for all user connection keys
        var server = _redis.GetServer(_redis.GetEndPoints().First());
        var keys = server.Keys(pattern: "user:connections:*");

        var onlineUsers = new List<string>();
        foreach (var key in keys)
        {
            var userId = key.ToString().Replace("user:connections:", "");
            onlineUsers.Add(userId);
        }

        return onlineUsers;
    }
}

// Presence Hub with Connection Tracking
public class PresenceHub : Hub
{
    private readonly IConnectionTracker _connectionTracker;

    public override async Task OnConnectedAsync()
    {
        var userId = Context.User.FindFirstValue(ClaimTypes.NameIdentifier);

        await _connectionTracker.AddConnectionAsync(userId, Context.ConnectionId);

        // Broadcast online status to all users
        await Clients.All.SendAsync("UserOnline", userId);

        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception exception)
    {
        var userId = Context.User.FindFirstValue(ClaimTypes.NameIdentifier);

        await _connectionTracker.RemoveConnectionAsync(userId, Context.ConnectionId);

        // Check if user has other connections
        var isStillOnline = await _connectionTracker.IsUserOnlineAsync(userId);

        if (!isStillOnline)
        {
            await Clients.All.SendAsync("UserOffline", userId);
        }

        await base.OnDisconnectedAsync(exception);
    }
}
```

**Azure SignalR Service (Managed Alternative):**

```csharp
// No Redis backplane needed - Azure handles scaling
public void ConfigureServices(IServiceCollection services)
{
    services.AddSignalR()
        .AddAzureSignalR(Configuration["Azure:SignalR:ConnectionString"]);
}

// Everything else stays the same!
// Azure SignalR Service handles:
// - Connection management (millions of connections)
// - Message routing between servers
// - Geo-distribution
// - Built-in monitoring and metrics
```

**Cost Comparison:**

| Solution | Cost | Scalability | Complexity |
|----------|------|-------------|------------|
| **In-Memory (Single Server)** | $50-200/mo | < 1K connections | Low |
| **Redis Backplane** | $100-500/mo | < 100K connections | Medium |
| **Azure SignalR Service** | $500-5000/mo | Millions | Low (managed) |

---

## 4. Server-Sent Events (SSE) Alternative

### When to Use SSE vs SignalR

**Use SSE when:**
- ✅ Server → Client only (notifications, live updates)
- ✅ Simpler than WebSocket (HTTP/1.1 compatible)
- ✅ Automatic reconnection built-in
- ✅ Text-based events (no binary)

**Use SignalR/WebSocket when:**
- ✅ Bi-directional (chat, collaboration)
- ✅ Need binary data (images, files)
- ✅ Lower latency required (gaming, trading)
- ✅ .NET ecosystem (SignalR is optimized)

### SSE Implementation

```csharp
// ASP.NET Core SSE Controller
[ApiController]
[Route("api/[controller]")]
public class EventStreamController : ControllerBase
{
    private readonly IEventBus _eventBus;

    [HttpGet("notifications")]
    public async Task StreamNotifications(CancellationToken cancellationToken)
    {
        Response.Headers.Add("Content-Type", "text/event-stream");
        Response.Headers.Add("Cache-Control", "no-cache");
        Response.Headers.Add("Connection", "keep-alive");

        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

        // Subscribe to user-specific events
        await foreach (var notification in _eventBus.SubscribeAsync(userId, cancellationToken))
        {
            // SSE format: data: {json}\n\n
            var sseMessage = $"data: {JsonSerializer.Serialize(notification)}\n\n";
            await Response.WriteAsync(sseMessage, cancellationToken);
            await Response.Body.FlushAsync(cancellationToken);
        }
    }

    [HttpGet("stock-prices")]
    public async Task StreamStockPrices(
        [FromQuery] string[] symbols,
        CancellationToken cancellationToken)
    {
        Response.Headers.Add("Content-Type", "text/event-stream");
        Response.Headers.Add("Cache-Control", "no-cache");

        while (!cancellationToken.IsCancellationRequested)
        {
            foreach (var symbol in symbols)
            {
                var price = await _stockService.GetLatestPriceAsync(symbol);

                // Named event type
                var sseMessage = $"event: price-update\n" +
                                $"data: {JsonSerializer.Serialize(new { symbol, price })}\n" +
                                $"id: {Guid.NewGuid()}\n\n";

                await Response.WriteAsync(sseMessage, cancellationToken);
                await Response.Body.FlushAsync(cancellationToken);
            }

            await Task.Delay(1000, cancellationToken); // Update every second
        }
    }
}

// Event Bus for Broadcasting
public class EventBus : IEventBus
{
    private readonly ConcurrentDictionary<string, List<Channel<object>>> _subscriptions = new();

    public async IAsyncEnumerable<object> SubscribeAsync(
        string userId,
        [EnumeratorCancellation] CancellationToken cancellationToken)
    {
        var channel = Channel.CreateUnbounded<object>();

        _subscriptions.AddOrUpdate(
            userId,
            _ => new List<Channel<object>> { channel },
            (_, list) => { list.Add(channel); return list; });

        try
        {
            await foreach (var item in channel.Reader.ReadAllAsync(cancellationToken))
            {
                yield return item;
            }
        }
        finally
        {
            // Cleanup on disconnect
            if (_subscriptions.TryGetValue(userId, out var channels))
            {
                channels.Remove(channel);
                if (channels.Count == 0)
                {
                    _subscriptions.TryRemove(userId, out _);
                }
            }
        }
    }

    public async Task PublishAsync(string userId, object notification)
    {
        if (_subscriptions.TryGetValue(userId, out var channels))
        {
            foreach (var channel in channels)
            {
                await channel.Writer.WriteAsync(notification);
            }
        }
    }
}
```

### React/TypeScript SSE Client

```typescript
// SSE Client Hook
export const useEventStream = (url: string) => {
    const [events, setEvents] = useState<any[]>([]);
    const [isConnected, setIsConnected] = useState(false);
    const eventSourceRef = useRef<EventSource | null>(null);

    useEffect(() => {
        const token = getAccessToken();
        const eventSource = new EventSource(`${url}?access_token=${token}`);

        eventSource.onopen = () => {
            setIsConnected(true);
            console.log('SSE connected');
        };

        eventSource.onmessage = (event) => {
            const data = JSON.parse(event.data);
            setEvents((prev) => [...prev, data]);
        };

        // Named event handler
        eventSource.addEventListener('price-update', (event) => {
            const data = JSON.parse(event.data);
            console.log('Price update:', data);
        });

        eventSource.onerror = (error) => {
            console.error('SSE error:', error);
            setIsConnected(false);
            // EventSource automatically reconnects
        };

        eventSourceRef.current = eventSource;

        return () => {
            eventSource.close();
        };
    }, [url]);

    return { events, isConnected };
};

// Usage
const NotificationFeed: React.FC = () => {
    const { events, isConnected } = useEventStream('/api/eventstream/notifications');

    return (
        <div>
            {!isConnected && <div>Connecting...</div>}
            {events.map((event, index) => (
                <div key={index}>{event.message}</div>
            ))}
        </div>
    );
};
```

---

## 5. Real Interview Scenarios

### Microsoft: Teams Presence System

**Question:** "Design a system like Microsoft Teams where millions of users can see each other's online/offline status in real-time."

**Answer:**

```csharp
// Architecture:
// Clients → SignalR Servers (Azure SignalR Service) → Redis → Presence Service

// 1. Presence Hub
public class PresenceHub : Hub
{
    private readonly IPresenceService _presenceService;

    public override async Task OnConnectedAsync()
    {
        var userId = Context.User.FindFirstValue(ClaimTypes.NameIdentifier);

        // Set user as online
        await _presenceService.SetUserOnlineAsync(userId);

        // Get user's contacts/team members
        var contacts = await _presenceService.GetUserContactsAsync(userId);

        // Notify contacts that this user is online
        foreach (var contactId in contacts)
        {
            await Clients.User(contactId).SendAsync("ContactOnline", userId);
        }

        // Send presence status of all contacts to this user
        var contactsPresence = await _presenceService.GetPresenceAsync(contacts);
        await Clients.Caller.SendAsync("ContactsPresence", contactsPresence);

        await base.OnConnectedAsync();
    }

    public async Task SetStatus(UserStatus status)
    {
        var userId = Context.User.FindFirstValue(ClaimTypes.NameIdentifier);

        await _presenceService.SetUserStatusAsync(userId, status);

        // Notify contacts of status change
        var contacts = await _presenceService.GetUserContactsAsync(userId);
        foreach (var contactId in contacts)
        {
            await Clients.User(contactId).SendAsync("ContactStatusChanged", userId, status);
        }
    }
}

// 2. Presence Service with Redis
public class PresenceService : IPresenceService
{
    private readonly IConnectionMultiplexer _redis;
    private readonly IDatabase _db;

    public async Task SetUserOnlineAsync(string userId)
    {
        await _db.StringSetAsync(
            $"presence:{userId}",
            JsonSerializer.Serialize(new { Status = "online", LastSeen = DateTime.UtcNow }),
            TimeSpan.FromMinutes(5)); // TTL - auto offline if no heartbeat
    }

    public async Task SetUserStatusAsync(string userId, UserStatus status)
    {
        await _db.StringSetAsync(
            $"presence:{userId}",
            JsonSerializer.Serialize(new { Status = status.ToString(), LastSeen = DateTime.UtcNow }),
            TimeSpan.FromMinutes(5));
    }

    public async Task<Dictionary<string, PresenceInfo>> GetPresenceAsync(List<string> userIds)
    {
        var pipeline = _db.CreateBatch();
        var tasks = userIds.Select(userId =>
            pipeline.StringGetAsync($"presence:{userId}")).ToArray();

        pipeline.Execute();

        await Task.WhenAll(tasks);

        var result = new Dictionary<string, PresenceInfo>();
        for (int i = 0; i < userIds.Count; i++)
        {
            var value = await tasks[i];
            if (value.HasValue)
            {
                result[userIds[i]] = JsonSerializer.Deserialize<PresenceInfo>(value);
            }
            else
            {
                result[userIds[i]] = new PresenceInfo { Status = "offline" };
            }
        }

        return result;
    }
}

// 3. React Client with Presence
const usePresence = () => {
    const [onlineUsers, setOnlineUsers] = useState<Map<string, UserStatus>>(new Map());
    const connectionRef = useRef<HubConnection | null>(null);

    useEffect(() => {
        const connection = new HubConnectionBuilder()
            .withUrl('/hubs/presence')
            .withAutomaticReconnect()
            .build();

        connection.on('ContactOnline', (userId: string) => {
            setOnlineUsers((prev) => new Map(prev).set(userId, 'online'));
        });

        connection.on('ContactOffline', (userId: string) => {
            setOnlineUsers((prev) => new Map(prev).set(userId, 'offline'));
        });

        connection.on('ContactStatusChanged', (userId: string, status: string) => {
            setOnlineUsers((prev) => new Map(prev).set(userId, status as UserStatus));
        });

        connection.start();
        connectionRef.current = connection;

        // Heartbeat every 2 minutes to maintain presence
        const heartbeat = setInterval(() => {
            connection.invoke('Heartbeat');
        }, 120000);

        return () => {
            clearInterval(heartbeat);
            connection.stop();
        };
    }, []);

    const setStatus = async (status: UserStatus) => {
        await connectionRef.current?.invoke('SetStatus', status);
    };

    return { onlineUsers, setStatus };
};
```

**Trade-offs Discussed:**
- "Azure SignalR Service handles millions of connections, eliminates need for Redis backplane"
- "TTL on presence keys auto-expires stale data if client disconnects ungracefully"
- "Batch Redis operations for getting presence of many users (avoid N+1)"
- "Contacts list limits fanout - don't broadcast to entire org (10K+ users)"

### Trading Platform: Real-Time Stock Prices

**Question:** "Design a system to push real-time stock prices to millions of clients. Some stocks update 100 times/sec."

**Answer:**

```csharp
// Architecture: Kafka → SignalR → Clients (with throttling)

// 1. Stock Price Consumer (from Kafka)
public class StockPriceConsumer : BackgroundService
{
    private readonly IHubContext<StockHub> _hubContext;
    private readonly IConsumer<string, string> _kafkaConsumer;
    private readonly Dictionary<string, ThrottledBroadcaster> _throttlers = new();

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _kafkaConsumer.Subscribe("stock-prices");

        while (!stoppingToken.IsCancellationRequested)
        {
            var result = _kafkaConsumer.Consume(stoppingToken);
            var priceUpdate = JsonSerializer.Deserialize<StockPrice>(result.Message.Value);

            // Throttle updates per symbol (max 1 update/sec to clients)
            if (!_throttlers.ContainsKey(priceUpdate.Symbol))
            {
                _throttlers[priceUpdate.Symbol] = new ThrottledBroadcaster(
                    _hubContext,
                    priceUpdate.Symbol,
                    TimeSpan.FromSeconds(1));
            }

            _throttlers[priceUpdate.Symbol].Enqueue(priceUpdate);
        }
    }
}

// 2. Throttled Broadcaster (prevents overwhelming clients)
public class ThrottledBroadcaster
{
    private readonly IHubContext<StockHub> _hubContext;
    private readonly string _symbol;
    private readonly Timer _timer;
    private StockPrice _latestPrice;

    public ThrottledBroadcaster(
        IHubContext<StockHub> hubContext,
        string symbol,
        TimeSpan interval)
    {
        _hubContext = hubContext;
        _symbol = symbol;
        _timer = new Timer(
            async _ => await BroadcastAsync(),
            null,
            interval,
            interval);
    }

    public void Enqueue(StockPrice price)
    {
        _latestPrice = price; // Only keep latest
    }

    private async Task BroadcastAsync()
    {
        if (_latestPrice != null)
        {
            await _hubContext.Clients
                .Group($"stock:{_symbol}")
                .SendAsync("PriceUpdate", _latestPrice);

            _latestPrice = null;
        }
    }
}

// 3. Stock Hub
public class StockHub : Hub
{
    public async Task SubscribeToSymbol(string symbol)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"stock:{symbol}");

        // Send latest price immediately
        var latestPrice = await _stockService.GetLatestPriceAsync(symbol);
        await Clients.Caller.SendAsync("PriceUpdate", latestPrice);
    }

    public async Task UnsubscribeFromSymbol(string symbol)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"stock:{symbol}");
    }
}

// 4. React Client with Throttling
const useStockPrice = (symbol: string) => {
    const [price, setPrice] = useState<number | null>(null);
    const [change, setChange] = useState<number>(0);
    const connectionRef = useRef<HubConnection | null>(null);

    useEffect(() => {
        const connection = new HubConnectionBuilder()
            .withUrl('/hubs/stock')
            .build();

        connection.on('PriceUpdate', (update: StockPrice) => {
            setPrice((prevPrice) => {
                if (prevPrice !== null) {
                    setChange(update.price - prevPrice);
                }
                return update.price;
            });
        });

        connection.start().then(() => {
            connection.invoke('SubscribeToSymbol', symbol);
        });

        connectionRef.current = connection;

        return () => {
            connection.invoke('UnsubscribeFromSymbol', symbol);
            connection.stop();
        };
    }, [symbol]);

    return { price, change };
};
```

**Interview Talking Points:**
- "Throttling on server prevents overwhelming clients (100 updates/sec → 1/sec)"
- "Groups enable targeted broadcasting - only subscribers get updates"
- "Kafka provides reliable event source, SignalR handles real-time push"
- "Latest-wins strategy (don't buffer all updates, only send most recent)"

---

## 6. Key Takeaways

**Tech Lead / Architect Level:**
1. **Protocol Selection** - SSE for server→client, WebSocket for bi-directional
2. **SignalR for .NET** - Abstracts protocol, handles fallback automatically
3. **Scaling with Redis** - Required for > 1K connections across multiple servers
4. **Azure SignalR Service** - Managed alternative, scales to millions
5. **Groups for Broadcasting** - Target specific users/rooms, avoid global fanout
6. **Throttling on Server** - Prevent overwhelming clients with high-frequency updates
7. **Presence with TTL** - Auto-expire stale connections in Redis
8. **Connection Lifecycle** - Handle reconnection, authentication, heartbeat
9. **Monitoring Critical** - Track connection count, message rate, latency
10. **Cost Optimization** - Single server → Redis → Azure SignalR based on scale

**Interview Preparation:**
- Be ready to compare WebSocket vs SSE vs Long Polling
- Explain SignalR architecture (Hubs, Groups, Backplane)
- Discuss scaling strategies (Redis backplane vs Azure SignalR)
- Walk through real-time scenarios (chat, notifications, presence, live updates)
- Know when to use SignalR vs Kafka vs EventGrid

**Red Flags to Avoid:**
- ❌ "I poll the server every second for updates" → Use push-based communication!
- ❌ "I broadcast to all users globally" → Use Groups for targeted messaging!
- ❌ "I don't handle reconnection" → Clients will stay disconnected!
- ❌ "I use SignalR without Redis for multiple servers" → Messages won't route!
- ❌ "I send raw data without throttling" → Clients will crash from overload!
