# Troubleshooting Guide

## Common Issues

### 1. Redis Connection Failed
**Error**: "Failed to connect to Redis"

**Solutions**:
```bash
# Test connection
redis-cli -h localhost -p 6379 ping

# Check firewall
# Check Redis is running
docker ps | grep redis
```

### 2. Namespace Errors
**Error**: "Type or namespace name 'IDistributedRateLimiterService' could not be found"

**Solution**:
```csharp
// Add to using statements:
using CareCoordination.Api.RateLimiting.Core;
```

### 3. Rate Limit Not Working
**Check**:
1. Verify `UseDistributedRateLimiting` in appsettings.json
2. Check Redis keys: `redis-cli keys "ratelimit:*"`
3. Enable logging in configuration

### 4. Concurrency Slots Not Released
**Solution**: Always use try-finally
```csharp
var (acquired, requestId) = await _rateLimiter.AcquireAsync(...);
try {
    // work
} finally {
    await _rateLimiter.ReleaseAsync(key, requestId); // MUST call
}
```

## Performance Issues

### High Latency
- Check Redis network latency
- Consider in-memory for internal endpoints
- Use connection pooling

### Memory Issues
- Reduce key TTL
- Use Fixed Window instead of Sliding Window
- Clean up old keys

## Configuration Issues

### Settings Not Applied
1. Check appsettings.json syntax
2. Verify environment-specific config
3. Restart application

### Redis Authentication
```json
{
  "RedisConnectionString": "host:6380,password=key,ssl=true"
}
```

## Getting Help
1. Check logs in Application Insights
2. Review Redis metrics
3. Test with simple Fixed Window first
