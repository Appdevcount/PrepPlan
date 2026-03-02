# C# Logging Conversion Task

## Objective
Convert all logging statements in C# files to structured logging format.

## Target Files
`*.cs` (C# files only)

## Log Methods to Convert
- `Log.Debug()`
- `Log.Error()`
- `Log.Warning()`
- `Log.Information()` (if present)

## New Format Template
sharp
Log.<Level>("Method={Method} <Custom Message> MessageKey={MessageKey}", methodName, messageKey)## Examples

### Before
Log.Warning("Validation failed")
Log.Error("Something went wrong")
Log.Debug("Processing data")### Afterarp
Log.Warning("Method={Method} Validation failed MessageKey={MessageKey}", methodName, messageKey)
Log.Error("Method={Method} Something went wrong MessageKey={MessageKey}", methodName, messageKey)
Log.Debug("Method={Method} Processing data MessageKey={MessageKey}", methodName, messageKey)

## Requirements
1. Keep the original log level (Debug, Error, Warning, etc.)
2. Preserve the original message text in the middle of the template
3. Add `Method={Method}` at the beginning of the message
4. Add `MessageKey={MessageKey}` at the end of the message
5. Add two parameters after the message: `methodName`, `messageKey`
6. Apply to all C# files in the codebase