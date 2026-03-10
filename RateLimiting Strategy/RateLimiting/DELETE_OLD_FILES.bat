@echo off
echo ================================================================
echo  CLEANING UP OLD RATE LIMITING FILES
echo ================================================================
echo.
echo This will DELETE the old scattered rate limiting files.
echo The new consolidated files are in Backend\CareCoordination.Api\RateLimiting\
echo.
pause

echo.
echo Deleting old files...

REM Delete old interface
del "Backend\CareCoordination.Application\Abstracts\ServiceInterfaces\IDistributedRateLimiterService.cs" 2>nul
if %errorlevel% == 0 (echo   [DELETED] IDistributedRateLimiterService.cs) else (echo   [SKIP] IDistributedRateLimiterService.cs not found)

REM Delete old service implementation
del "Backend\CareCoordination.Services\Implementation\DistributedRateLimiterService.cs" 2>nul
if %errorlevel% == 0 (echo   [DELETED] DistributedRateLimiterService.cs) else (echo   [SKIP] DistributedRateLimiterService.cs not found)

REM Delete old Redis limiters
del "Backend\CareCoordination.Services\RateLimiting\RedisFixedWindowRateLimiter.cs" 2>nul
if %errorlevel% == 0 (echo   [DELETED] RedisFixedWindowRateLimiter.cs) else (echo   [SKIP] RedisFixedWindowRateLimiter.cs not found)

del "Backend\CareCoordination.Services\RateLimiting\RedisSlidingWindowRateLimiter.cs" 2>nul
if %errorlevel% == 0 (echo   [DELETED] RedisSlidingWindowRateLimiter.cs) else (echo   [SKIP] RedisSlidingWindowRateLimiter.cs not found)

del "Backend\CareCoordination.Services\RateLimiting\RedisTokenBucketRateLimiter.cs" 2>nul
if %errorlevel% == 0 (echo   [DELETED] RedisTokenBucketRateLimiter.cs) else (echo   [SKIP] RedisTokenBucketRateLimiter.cs not found)

del "Backend\CareCoordination.Services\RateLimiting\RedisConcurrencyRateLimiter.cs" 2>nul
if %errorlevel% == 0 (echo   [DELETED] RedisConcurrencyRateLimiter.cs) else (echo   [SKIP] RedisConcurrencyRateLimiter.cs not found)

REM Delete old config
del "Backend\CareCoordination.Services\Models\RateLimiterConfig.cs" 2>nul
if %errorlevel% == 0 (echo   [DELETED] RateLimiterConfig.cs) else (echo   [SKIP] RateLimiterConfig.cs not found)

REM Delete old extensions
del "Backend\CareCoordination.Api\Extensions\DistributedRateLimiterExtensions.cs" 2>nul
if %errorlevel% == 0 (echo   [DELETED] DistributedRateLimiterExtensions.cs) else (echo   [SKIP] DistributedRateLimiterExtensions.cs not found)

REM Delete old controller
del "Backend\CareCoordination.Api\Controllers\RateLimitExampleController.cs" 2>nul
if %errorlevel% == 0 (echo   [DELETED] RateLimitExampleController.cs) else (echo   [SKIP] RateLimitExampleController.cs not found)

echo.
echo ================================================================
echo  CLEANUP COMPLETE!
echo ================================================================
echo.
echo All old files have been removed.
echo New consolidated files are in:
echo   Backend\CareCoordination.Api\RateLimiting\
echo.
pause
