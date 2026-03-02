using System.Security.Cryptography;
using System.Text;

namespace Webhooks;

// Validates incoming webhook requests against a shared HMAC-SHA256 secret.
//
// Validation steps (in order):
//   1. Signature header must be present
//   2. Timestamp must be within tolerance window (replay protection)
//   3. HMAC-SHA256 of raw body must match the header value
//   4. Comparison must use constant-time equals (timing attack prevention)
public sealed class WebhookSignatureValidator(IConfiguration config)
{
    private readonly string _secret =
        config["Webhook:Secret"]
        ?? throw new InvalidOperationException(
            "Webhook:Secret is not configured. Add it to appsettings.json.");

    // How old an event can be before we reject it (default: 300s = 5 minutes)
    private readonly int _toleranceSeconds =
        int.Parse(config["Webhook:TimestampToleranceSeconds"] ?? "300");

    public ValidationResult Validate(IHeaderDictionary headers, byte[] rawBody)
    {
        // ── Step 1: signature header must be present ─────────────────────────
        if (!headers.TryGetValue("X-Webhook-Signature", out var sigHeader)
            || string.IsNullOrEmpty(sigHeader))
            return ValidationResult.Fail("Missing X-Webhook-Signature header");

        // ── Step 2: timestamp replay protection ──────────────────────────────
        // WHY: without this, an attacker who captures a valid signed request
        // can replay it indefinitely. The 5-minute window is industry standard.
        if (headers.TryGetValue("X-Webhook-Timestamp", out var tsHeader)
            && long.TryParse(tsHeader, out var unixTs))
        {
            var eventTime  = DateTimeOffset.FromUnixTimeSeconds(unixTs);
            var ageSeconds = Math.Abs((DateTimeOffset.UtcNow - eventTime).TotalSeconds);
            if (ageSeconds > _toleranceSeconds)
                return ValidationResult.Fail(
                    $"Timestamp too old ({ageSeconds:F0}s > {_toleranceSeconds}s tolerance)");
        }

        // ── Step 3: compute expected HMAC-SHA256 over raw body bytes ──────────
        // WHY raw bytes: signature is over the exact bytes received, not a re-serialized string
        var key          = Encoding.UTF8.GetBytes(_secret);
        using var hmac   = new HMACSHA256(key);
        var expectedHash = hmac.ComputeHash(rawBody);
        var expectedSig  = "sha256=" + Convert.ToHexString(expectedHash).ToLowerInvariant();

        // ── Step 4: constant-time comparison ─────────────────────────────────
        // WHY NOT string ==: string equality returns early on first mismatch,
        // allowing timing attacks to guess the secret character by character.
        // CryptographicOperations.FixedTimeEquals always runs to completion.
        var actualSig = sigHeader.ToString();
        if (actualSig.Length != expectedSig.Length)
            return ValidationResult.Fail("Signature length mismatch");

        var actualBytes   = Encoding.UTF8.GetBytes(actualSig);
        var expectedBytes = Encoding.UTF8.GetBytes(expectedSig);

        return CryptographicOperations.FixedTimeEquals(actualBytes, expectedBytes)
            ? ValidationResult.Ok()
            : ValidationResult.Fail("Signature mismatch");
    }
}

public record ValidationResult(bool IsValid, string? Error)
{
    public static ValidationResult Ok()              => new(true, null);
    public static ValidationResult Fail(string error) => new(false, error);
}
