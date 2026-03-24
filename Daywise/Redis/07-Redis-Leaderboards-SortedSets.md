# Redis — Leaderboards, Priority Queues & Sorted Set Patterns in .NET

> **Mental Model:** A Sorted Set is a scoreboard at an arcade — every player has a score.
> Players are automatically ordered by score. You can instantly ask:
> "Who's in the top 10?" or "What's Alice's rank?" in O(log N) time.

---

## Table of Contents
1. [Sorted Set Recap](#sorted-set-recap)
2. [Gaming Leaderboard](#gaming-leaderboard)
3. [Multi-Period Leaderboards (Daily / Weekly / All-Time)](#multi-period-leaderboards)
4. [Priority Queue](#priority-queue)
5. [Time-Based Event Queue (Delayed Jobs)](#time-based-event-queue-delayed-jobs)
6. [Activity Feed / Timeline](#activity-feed--timeline)
7. [Top-N Analytics](#top-n-analytics)
8. [Geospatial Leaderboard](#geospatial-leaderboard)
9. [Trending Items (Decaying Score)](#trending-items-decaying-score)
10. [Set Aggregation Operations](#set-aggregation-operations)

---

## Sorted Set Recap

```
ZADD key score member       → Add/update member with score
ZINCRBY key delta member    → Atomic score increment
ZRANK key member            → 0-based rank (ascending)
ZREVRANK key member         → 0-based rank (descending, 0 = highest score)
ZSCORE key member           → Get member's score
ZRANGE key 0 -1             → All members (ascending by score)
ZREVRANGE key 0 9           → Top 10 (descending by score)     [deprecated: use ZRANGE ... REV]
ZRANGEBYSCORE key min max   → Members in score range
ZRANGEBYLEX key [a [z       → Members in lexicographic range (same score)
ZCARD key                   → Total member count
ZREM key member             → Remove member
ZPOPMIN / ZPOPMAX           → Pop lowest/highest score member (atomic)
ZUNIONSTORE / ZINTERSTORE   → Set operations storing result in new key
```

---

## Gaming Leaderboard

```csharp
public class LeaderboardService
{
    private readonly IDatabase _db;

    // ── Add / Update player score ──────────────────────────────────────
    public async Task AddScoreAsync(string leaderboardId, string playerId, double score)
    {
        // WHY: ZADD always updates if player already exists (overwrite, not add)
        await _db.SortedSetAddAsync($"leaderboard:{leaderboardId}", playerId, score);
    }

    public async Task IncrementScoreAsync(string leaderboardId, string playerId, double delta)
    {
        // WHY: ZINCRBY is atomic — safe across concurrent game servers
        await _db.SortedSetIncrementAsync($"leaderboard:{leaderboardId}", playerId, delta);
    }

    // ── Get top N players ─────────────────────────────────────────────
    public async Task<IEnumerable<LeaderboardEntry>> GetTopPlayersAsync(
        string leaderboardId, int topN = 10)
    {
        var entries = await _db.SortedSetRangeByRankWithScoresAsync(
            $"leaderboard:{leaderboardId}",
            start: 0,
            stop: topN - 1,
            order: Order.Descending); // WHY: Descending = highest score first

        return entries.Select((e, i) => new LeaderboardEntry(
            Rank: i + 1,
            PlayerId: e.Element.ToString(),
            Score: e.Score));
    }

    // ── Get player's rank ─────────────────────────────────────────────
    public async Task<PlayerRankInfo?> GetPlayerRankAsync(string leaderboardId, string playerId)
    {
        var rank = await _db.SortedSetRankAsync(
            $"leaderboard:{leaderboardId}", playerId, Order.Descending);

        var score = await _db.SortedSetScoreAsync($"leaderboard:{leaderboardId}", playerId);

        if (!rank.HasValue) return null;

        return new PlayerRankInfo(
            PlayerId: playerId,
            Rank: rank.Value + 1, // Convert 0-based to 1-based
            Score: score ?? 0,
            TotalPlayers: await _db.SortedSetLengthAsync($"leaderboard:{leaderboardId}"));
    }

    // ── Get players around a specific player (neighborhood) ───────────
    public async Task<IEnumerable<LeaderboardEntry>> GetNeighborhoodAsync(
        string leaderboardId, string playerId, int range = 2)
    {
        var rank = await _db.SortedSetRankAsync(
            $"leaderboard:{leaderboardId}", playerId, Order.Descending);

        if (!rank.HasValue) return Enumerable.Empty<LeaderboardEntry>();

        long start = Math.Max(0, rank.Value - range);
        long stop = rank.Value + range;

        var entries = await _db.SortedSetRangeByRankWithScoresAsync(
            $"leaderboard:{leaderboardId}", start, stop, Order.Descending);

        return entries.Select((e, i) => new LeaderboardEntry(
            Rank: (int)(start + i + 1),
            PlayerId: e.Element.ToString(),
            Score: e.Score));
    }

    // ── Get score for a range of ranks ────────────────────────────────
    public async Task<IEnumerable<LeaderboardEntry>> GetRangeAsync(
        string leaderboardId, int fromRank, int toRank)
    {
        var entries = await _db.SortedSetRangeByRankWithScoresAsync(
            $"leaderboard:{leaderboardId}",
            fromRank - 1, toRank - 1, Order.Descending);

        return entries.Select((e, i) => new LeaderboardEntry(
            Rank: fromRank + i,
            PlayerId: e.Element.ToString(),
            Score: e.Score));
    }

    // ── Count players in score range ───────────────────────────────────
    public async Task<long> CountInScoreRangeAsync(
        string leaderboardId, double minScore, double maxScore)
        => await _db.SortedSetLengthAsync($"leaderboard:{leaderboardId}", minScore, maxScore);

    // ── Remove player ─────────────────────────────────────────────────
    public async Task RemovePlayerAsync(string leaderboardId, string playerId)
        => await _db.SortedSetRemoveAsync($"leaderboard:{leaderboardId}", playerId);
}

public record LeaderboardEntry(int Rank, string PlayerId, double Score);
public record PlayerRankInfo(string PlayerId, long Rank, double Score, long TotalPlayers);
```

---

## Multi-Period Leaderboards

> **Mental Model:** Three separate scoreboards — one resets daily, one weekly, one permanent.

```csharp
public class MultiPeriodLeaderboard
{
    private readonly IDatabase _db;

    private string DailyKey(string game)
        => $"leaderboard:{game}:daily:{DateTime.UtcNow:yyyy-MM-dd}";

    private string WeeklyKey(string game)
    {
        // WHY: ISO week number ensures consistent Monday-Sunday weeks
        var culture = System.Globalization.CultureInfo.InvariantCulture;
        int week = culture.Calendar.GetWeekOfYear(
            DateTime.UtcNow, System.Globalization.CalendarWeekRule.FirstFourDayWeek,
            DayOfWeek.Monday);
        return $"leaderboard:{game}:weekly:{DateTime.UtcNow.Year}-W{week:D2}";
    }

    private string AllTimeKey(string game) => $"leaderboard:{game}:alltime";

    public async Task RecordScoreAsync(string game, string playerId, double score)
    {
        // WHY: Pipeline all three updates in one round trip
        var batch = _db.CreateBatch();

        var dailyTask = batch.SortedSetIncrementAsync(DailyKey(game), playerId, score);
        var weeklyTask = batch.SortedSetIncrementAsync(WeeklyKey(game), playerId, score);
        var allTimeTask = batch.SortedSetIncrementAsync(AllTimeKey(game), playerId, score);

        // Set TTL on daily and weekly keys (auto-cleanup old periods)
        var dailyTtl = batch.KeyExpireAsync(DailyKey(game), TimeSpan.FromDays(2));
        var weeklyTtl = batch.KeyExpireAsync(WeeklyKey(game), TimeSpan.FromDays(14));

        batch.Execute();
        await Task.WhenAll(dailyTask, weeklyTask, allTimeTask, dailyTtl, weeklyTtl);
    }

    public async Task<Dictionary<string, IEnumerable<LeaderboardEntry>>> GetAllPeriodsAsync(
        string game, int topN = 10)
    {
        // WHY: Fetch all periods in parallel
        var (daily, weekly, allTime) = await (
            GetTopAsync(DailyKey(game), topN),
            GetTopAsync(WeeklyKey(game), topN),
            GetTopAsync(AllTimeKey(game), topN)
        ).WhenAll();

        return new Dictionary<string, IEnumerable<LeaderboardEntry>>
        {
            ["daily"] = daily,
            ["weekly"] = weekly,
            ["allTime"] = allTime
        };
    }

    private async Task<IEnumerable<LeaderboardEntry>> GetTopAsync(string key, int n)
    {
        var entries = await _db.SortedSetRangeByRankWithScoresAsync(key, 0, n - 1, Order.Descending);
        return entries.Select((e, i) => new LeaderboardEntry(i + 1, e.Element.ToString(), e.Score));
    }
}

// Extension for parallel task tuples
public static class TaskExtensions
{
    public static async Task<(T1, T2, T3)> WhenAll<T1, T2, T3>(
        this (Task<T1> t1, Task<T2> t2, Task<T3> t3) tasks)
    {
        await Task.WhenAll(tasks.t1, tasks.t2, tasks.t3);
        return (tasks.t1.Result, tasks.t2.Result, tasks.t3.Result);
    }
}
```

---

## Priority Queue

> **Mental Model:** Job queue where each job has a priority number.
> Lower number = higher priority (like a hospital triage — 1 is critical, 5 is routine).

```csharp
// WHY: Sorted Set as priority queue — score = priority (lower = more urgent)
// ZPOPMIN atomically removes and returns the lowest-score (highest-priority) item
public class RedisPriorityQueue
{
    private readonly IDatabase _db;
    private readonly string _queueKey;

    public RedisPriorityQueue(IConnectionMultiplexer redis, string queueName)
    {
        _db = redis.GetDatabase();
        _queueKey = $"pqueue:{queueName}";
    }

    public async Task EnqueueAsync<T>(T item, double priority)
    {
        // WHY: Include GUID in member to allow multiple items with same priority
        string member = $"{Guid.NewGuid():N}:{JsonSerializer.Serialize(item)}";
        await _db.SortedSetAddAsync(_queueKey, member, priority);
    }

    // Dequeue highest-priority item (lowest score)
    public async Task<(T? Item, double Priority)> DequeueAsync<T>()
    {
        // WHY: ZPOPMIN is atomic — safe across multiple consumers
        var entries = await _db.SortedSetPopAsync(_queueKey, Order.Ascending);

        if (!entries.Any()) return default;

        var entry = entries[0];
        var parts = entry.Element.ToString().Split(':', 2);
        var item = JsonSerializer.Deserialize<T>(parts[1])!;

        return (item, entry.Score);
    }

    // Peek without removing
    public async Task<(T? Item, double Priority)?> PeekAsync<T>()
    {
        var entries = await _db.SortedSetRangeByRankWithScoresAsync(_queueKey, 0, 0);
        if (!entries.Any()) return null;

        var entry = entries[0];
        var parts = entry.Element.ToString().Split(':', 2);
        return (JsonSerializer.Deserialize<T>(parts[1])!, entry.Score);
    }

    public async Task<long> LengthAsync() => await _db.SortedSetLengthAsync(_queueKey);
}

// Usage
var queue = new RedisPriorityQueue(redis, "support-tickets");
await queue.EnqueueAsync(new SupportTicket("P1 - Server down"), priority: 1);
await queue.EnqueueAsync(new SupportTicket("P3 - UI issue"), priority: 3);
await queue.EnqueueAsync(new SupportTicket("P2 - Login failing"), priority: 2);

var (ticket, priority) = await queue.DequeueAsync<SupportTicket>();
// Returns: "P1 - Server down" (lowest priority number = most urgent)
```

---

## Time-Based Event Queue (Delayed Jobs)

> **Mental Model:** A calendar where each item has a "run at" timestamp as the score.
> A worker periodically checks for items whose score (timestamp) has passed.

```csharp
// WHY: Sorted Set with score = Unix timestamp enables schedule-based job processing
// Worker polls for jobs whose score <= now
public class DelayedJobQueue
{
    private readonly IDatabase _db;
    private const string QueueKey = "delayed-jobs";

    // Schedule a job to run at a future time
    public async Task ScheduleAsync<T>(T job, DateTime runAt)
    {
        double score = new DateTimeOffset(runAt).ToUnixTimeMilliseconds();
        string member = JsonSerializer.Serialize(new DelayedJob<T>(
            Guid.NewGuid().ToString(),
            job,
            runAt));

        await _db.SortedSetAddAsync(QueueKey, member, score);
    }

    public async Task ScheduleAfterAsync<T>(T job, TimeSpan delay)
        => await ScheduleAsync(job, DateTime.UtcNow + delay);

    // Claim due jobs atomically (Lua script)
    public async Task<IEnumerable<string>> ClaimDueJobsAsync(int maxBatch = 10)
    {
        double now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

        // WHY: Lua script atomically reads and removes due jobs
        // Without atomicity, two workers could claim the same job
        const string script = @"
            local jobs = redis.call('ZRANGEBYSCORE', KEYS[1], '-inf', ARGV[1], 'LIMIT', 0, ARGV[2])
            if #jobs == 0 then return {} end
            redis.call('ZREM', KEYS[1], unpack(jobs))
            return jobs";

        var result = await _db.ScriptEvaluateAsync(script,
            new RedisKey[] { QueueKey },
            new RedisValue[] { now, maxBatch });

        if (result.IsNull) return Enumerable.Empty<string>();
        return ((RedisResult[])result!).Select(r => r.ToString()!);
    }
}

// Worker
public class DelayedJobWorker : BackgroundService
{
    private readonly DelayedJobQueue _queue;
    private readonly IJobDispatcher _dispatcher;

    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            var dueJobs = await _queue.ClaimDueJobsAsync(maxBatch: 10);

            foreach (var jobJson in dueJobs)
                await _dispatcher.DispatchAsync(jobJson, ct);

            if (!dueJobs.Any())
                await Task.Delay(TimeSpan.FromSeconds(1), ct);
        }
    }
}

public record DelayedJob<T>(string Id, T Payload, DateTime ScheduledAt);
```

---

## Activity Feed / Timeline

```csharp
// WHY: Sorted Set with score = timestamp = instant time-ordered feed retrieval
// Fan-out on write: when user posts, add to all followers' feeds
public class ActivityFeedService
{
    private readonly IDatabase _db;
    private readonly IFollowerRepository _followers;
    private const int MaxFeedSize = 1000;

    // Post activity (fan-out to all followers)
    public async Task PostActivityAsync(Activity activity)
    {
        var followers = await _followers.GetFollowersAsync(activity.AuthorId);
        var score = new DateTimeOffset(activity.Timestamp).ToUnixTimeMilliseconds();
        var json = JsonSerializer.Serialize(activity);

        // WHY: Fan-out on write — O(followers) work at write time for O(1) read time
        // For celebrities with millions of followers, use fan-out on read (pull model) instead
        var tasks = followers.Select(followerId =>
            AddToFeedAsync(followerId, activity.Id, json, score));

        await Task.WhenAll(tasks);
    }

    private async Task AddToFeedAsync(string userId, string activityId, string json, double score)
    {
        string feedKey = $"feed:{userId}";

        // WHY: Cache the JSON in a separate key; store only ID in sorted set
        // Prevents duplicated large payloads when same activity appears in many feeds
        await _db.StringSetAsync($"activity:{activityId}", json, TimeSpan.FromDays(30));
        await _db.SortedSetAddAsync(feedKey, activityId, score);

        // WHY: Cap feed at MaxFeedSize to prevent memory bloat
        await _db.SortedSetRemoveRangeByRankAsync(feedKey, 0, -(MaxFeedSize + 1));
    }

    // Get paginated feed
    public async Task<FeedPage> GetFeedAsync(string userId, int page = 1, int pageSize = 20)
    {
        string feedKey = $"feed:{userId}";
        long start = (page - 1) * pageSize;
        long stop = start + pageSize - 1;

        // WHY: Descending order = newest first (highest timestamp score first)
        var activityIds = await _db.SortedSetRangeByRankAsync(
            feedKey, start, stop, Order.Descending);

        // WHY: Pipeline fetch all activity payloads in one round trip
        var batch = _db.CreateBatch();
        var tasks = activityIds
            .Select(id => batch.StringGetAsync($"activity:{id}"))
            .ToList();
        batch.Execute();

        var results = await Task.WhenAll(tasks);
        var activities = results
            .Where(r => r.HasValue)
            .Select(r => JsonSerializer.Deserialize<Activity>(r!.ToString()!))
            .ToList();

        long total = await _db.SortedSetLengthAsync(feedKey);

        return new FeedPage(activities!, total, page, pageSize);
    }
}

public record Activity(string Id, string AuthorId, string Type, string Content, DateTime Timestamp);
public record FeedPage(List<Activity> Items, long Total, int Page, int PageSize);
```

---

## Top-N Analytics

```csharp
// WHY: Sorted Set maintains ordered list — perfect for top-N without full scans
public class AnalyticsService
{
    private readonly IDatabase _db;

    // Track most viewed products
    public async Task TrackViewAsync(string productId)
    {
        string today = DateTime.UtcNow.ToString("yyyy-MM-dd");
        await _db.SortedSetIncrementAsync($"analytics:views:{today}", productId, 1);
    }

    // Track search terms
    public async Task TrackSearchAsync(string term)
        => await _db.SortedSetIncrementAsync("analytics:searches", term.ToLower(), 1);

    // Get top N items
    public async Task<IEnumerable<(string Item, double Count)>> GetTopAsync(
        string metricKey, int topN = 10)
    {
        var entries = await _db.SortedSetRangeByRankWithScoresAsync(
            metricKey, 0, topN - 1, Order.Descending);

        return entries.Select(e => (e.Element.ToString(), e.Score));
    }

    // Trending: aggregate this week's top vs last week
    public async Task<IEnumerable<string>> GetTrendingProductsAsync(int topN = 10)
    {
        string thisWeek = $"analytics:views:{DateTime.UtcNow:yyyy-MM-dd}";
        string lastWeek = $"analytics:views:{DateTime.UtcNow.AddDays(-7):yyyy-MM-dd}";
        string trendingKey = "analytics:trending:current";

        // WHY: ZUNIONSTORE combines scores across multiple keys
        // Weight current week 2x more than last week
        await _db.SortedSetCombineAndStoreAsync(
            SetOperation.Union,
            trendingKey,
            new RedisKey[] { thisWeek, lastWeek },
            new double[] { 2.0, 1.0 }); // Weights

        await _db.KeyExpireAsync(trendingKey, TimeSpan.FromHours(1));

        var top = await _db.SortedSetRangeByRankAsync(trendingKey, 0, topN - 1, Order.Descending);
        return top.Select(e => e.ToString());
    }
}
```

---

## Trending Items (Decaying Score)

> **Mental Model:** Hot content cools over time. Score = engagement / time^decay_factor.
> Newer content with same engagement ranks higher.

```csharp
// WHY: Time-decayed scoring keeps trending feed fresh without manual cleanup
public class TrendingService
{
    private readonly IDatabase _db;
    private const string TrendingKey = "trending:posts";

    // Calculate decayed score: engagements / (age_in_hours + 2)^gravity
    private double CalculateScore(long engagements, DateTime createdAt, double gravity = 1.8)
    {
        var ageHours = (DateTime.UtcNow - createdAt).TotalHours;
        return engagements / Math.Pow(ageHours + 2, gravity);
    }

    public async Task UpdatePostScoreAsync(string postId, long totalEngagements, DateTime createdAt)
    {
        double score = CalculateScore(totalEngagements, createdAt);
        await _db.SortedSetAddAsync(TrendingKey, postId, score);
    }

    // Background worker: periodically recalculate scores (scores decay over time)
    public async Task RecalculateAllScoresAsync(IEnumerable<PostStats> posts)
    {
        var entries = posts.Select(p =>
            new SortedSetEntry(p.PostId, CalculateScore(p.TotalEngagements, p.CreatedAt)))
            .ToArray();

        // WHY: ZADD updates existing entries — scores decay automatically
        await _db.SortedSetAddAsync(TrendingKey, entries);

        // Prune items with very low scores (no longer trending)
        await _db.SortedSetRemoveRangeByScoreAsync(TrendingKey, 0, 0.001);
    }
}

public record PostStats(string PostId, long TotalEngagements, DateTime CreatedAt);
```

---

## Set Aggregation Operations

```csharp
// ZUNIONSTORE, ZINTERSTORE — combine sorted sets
public class SetAggregationService
{
    private readonly IDatabase _db;

    // Find users active in ALL selected periods (intersection)
    public async Task<string[]> GetUsersActiveInAllPeriodsAsync(params string[] periodKeys)
    {
        string resultKey = $"temp:intersection:{Guid.NewGuid():N}";

        await _db.SortedSetCombineAndStoreAsync(
            SetOperation.Intersect,
            resultKey,
            periodKeys.Select(k => (RedisKey)k).ToArray());

        await _db.KeyExpireAsync(resultKey, TimeSpan.FromSeconds(60)); // WHY: temp key cleanup

        var members = await _db.SortedSetRangeByRankAsync(resultKey, 0, -1);
        return members.Select(m => m.ToString()).ToArray();
    }

    // Combine leaderboards from multiple game modes
    public async Task CreateCombinedLeaderboardAsync(
        string[] sourceKeys, string destinationKey, double[] weights = null!)
    {
        weights ??= Enumerable.Repeat(1.0, sourceKeys.Length).ToArray();

        await _db.SortedSetCombineAndStoreAsync(
            SetOperation.Union,
            destinationKey,
            sourceKeys.Select(k => (RedisKey)k).ToArray(),
            weights,
            Aggregate.Sum); // Sum scores from all source leaderboards

        await _db.KeyExpireAsync(destinationKey, TimeSpan.FromHours(1));
    }

    // Users in leaderboard A but NOT in leaderboard B
    public async Task<string[]> GetUniquePlayersAsync(string boardA, string boardB)
    {
        // WHY: No native ZDIFF before Redis 6.2 — use Lua for older versions
        string resultKey = $"temp:diff:{Guid.NewGuid():N}";

        await _db.SortedSetCombineAndStoreAsync(
            SetOperation.Difference,
            resultKey,
            new RedisKey[] { boardA, boardB });

        await _db.KeyExpireAsync(resultKey, TimeSpan.FromSeconds(30));
        var members = await _db.SortedSetRangeByRankAsync(resultKey, 0, -1);
        return members.Select(m => m.ToString()).ToArray();
    }
}
```

---

## Quick Reference: Sorted Set Complexity

```
┌──────────────────────────┬──────────────┬──────────────────────────────┐
│ Operation                │ Complexity   │ Notes                        │
├──────────────────────────┼──────────────┼──────────────────────────────┤
│ ZADD                     │ O(log N)     │ N = current set size         │
│ ZINCRBY                  │ O(log N)     │ Atomic                       │
│ ZSCORE                   │ O(1)         │                              │
│ ZRANK / ZREVRANK         │ O(log N)     │                              │
│ ZRANGE (by rank)         │ O(log N + M) │ M = returned elements        │
│ ZRANGEBYSCORE            │ O(log N + M) │                              │
│ ZREM                     │ O(log N * M) │ M = elements removed         │
│ ZCARD                    │ O(1)         │                              │
│ ZPOPMIN / ZPOPMAX        │ O(log N * M) │ Atomic                       │
│ ZUNIONSTORE              │ O(N*K+M*log M)│ K = sets, M = result size  │
│ ZINTERSTORE              │ O(N*K+M*log M)│                             │
└──────────────────────────┴──────────────┴──────────────────────────────┘
```

---

*Next:* [08-Redis-Advanced-Patterns.md](08-Redis-Advanced-Patterns.md) — Lua scripting, pipelines, transactions, Bloom filters, search, and production tuning
