@echo off
echo ================================================================
echo  CONSOLIDATING RATE LIMITING FILES
echo ================================================================
echo.

REM Create target directories
echo Creating target directories...
mkdir "Backend\CareCoordination.Api\RateLimiting\Core" 2>nul
mkdir "Backend\CareCoordination.Api\RateLimiting\Redis" 2>nul
mkdir "Backend\CareCoordination.Api\RateLimiting\Configuration" 2>nul
mkdir "Backend\CareCoordination.Api\RateLimiting\Examples" 2>nul

REM Copy Core files
echo.
echo Copying Core files...
copy /Y "Backend\CareCoordination.Application\Abstracts\ServiceInterfaces\IDistributedRateLimiterService.cs" "Backend\CareCoordination.Api\RateLimiting\Core\" >nul
if %errorlevel% == 0 (echo   [OK] IDistributedRateLimiterService.cs) else (echo   [FAIL] IDistributedRateLimiterService.cs)

copy /Y "Backend\CareCoordination.Services\Implementation\DistributedRateLimiterService.cs" "Backend\CareCoordination.Api\RateLimiting\Core\" >nul
if %errorlevel% == 0 (echo   [OK] DistributedRateLimiterService.cs) else (echo   [FAIL] DistributedRateLimiterService.cs)

REM Copy Redis limiters
echo.
echo Copying Redis limiter implementations...
copy /Y "Backend\CareCoordination.Services\RateLimiting\RedisFixedWindowRateLimiter.cs" "Backend\CareCoordination.Api\RateLimiting\Redis\" >nul
if %errorlevel% == 0 (echo   [OK] RedisFixedWindowRateLimiter.cs) else (echo   [FAIL] RedisFixedWindowRateLimiter.cs)

copy /Y "Backend\CareCoordination.Services\RateLimiting\RedisSlidingWindowRateLimiter.cs" "Backend\CareCoordination.Api\RateLimiting\Redis\" >nul
if %errorlevel% == 0 (echo   [OK] RedisSlidingWindowRateLimiter.cs) else (echo   [FAIL] RedisSlidingWindowRateLimiter.cs)

copy /Y "Backend\CareCoordination.Services\RateLimiting\RedisTokenBucketRateLimiter.cs" "Backend\CareCoordination.Api\RateLimiting\Redis\" >nul
if %errorlevel% == 0 (echo   [OK] RedisTokenBucketRateLimiter.cs) else (echo   [FAIL] RedisTokenBucketRateLimiter.cs)

copy /Y "Backend\CareCoordination.Services\RateLimiting\RedisConcurrencyRateLimiter.cs" "Backend\CareCoordination.Api\RateLimiting\Redis\" >nul
if %errorlevel% == 0 (echo   [OK] RedisConcurrencyRateLimiter.cs) else (echo   [FAIL] RedisConcurrencyRateLimiter.cs)

REM Copy Configuration
echo.
echo Copying Configuration files...
copy /Y "Backend\CareCoordination.Services\Models\RateLimiterConfig.cs" "Backend\CareCoordination.Api\RateLimiting\Configuration\" >nul
if %errorlevel% == 0 (echo   [OK] RateLimiterConfig.cs) else (echo   [FAIL] RateLimiterConfig.cs)

copy /Y "Backend\CareCoordination.Api\Extensions\DistributedRateLimiterExtensions.cs" "Backend\CareCoordination.Api\RateLimiting\Configuration\" >nul
if %errorlevel% == 0 (echo   [OK] DistributedRateLimiterExtensions.cs) else (echo   [FAIL] DistributedRateLimiterExtensions.cs)

REM Copy Examples
echo.
echo Copying Example controller...
copy /Y "Backend\CareCoordination.Api\Controllers\RateLimitExampleController.cs" "Backend\CareCoordination.Api\RateLimiting\Examples\" >nul
if %errorlevel% == 0 (echo   [OK] RateLimitExampleController.cs) else (echo   [FAIL] RateLimitExampleController.cs)

echo.
echo ================================================================
echo  FILES CONSOLIDATED SUCCESSFULLY!
echo ================================================================
echo.
echo All rate limiting files are now in:
echo   Backend\CareCoordination.Api\RateLimiting\
echo.
echo NEXT STEPS:
echo   1. Update namespaces in the moved files
echo   2. Update using statements in Program.cs
echo   3. Rebuild solution
echo.
pause
