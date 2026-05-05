# Log Reporter

A comprehensive logging solution for Flutter applications that provides a unified logging interface with automatic configuration through dependency injection.

## Features

- **Unified Logging Interface**: Simple, consistent API with `debug()` and `error()` methods
- **Automatic Configuration**: Pre-configured logging setup through module configurator
- **Multiple Destinations**: Automatically logs to both local console and Firebase Crashlytics
- **Cross-Platform**: Works on Android, iOS, macOS, and Web platforms
- **Structured Logging**: Support for tags, error objects, and stack traces
- **Workspace Integration**: Follows workspace development patterns with proper dependency injection

## Getting Started

### Installation

This module is part of the workspace and can be imported directly:

```dart
import 'package:log_reporter/log_reporter.dart';
```

### Module Configuration

Add the log reporter module configurator to your application setup:

```dart
import 'package:log_reporter/log_reporter.dart';

// Add to your module configurators
final configurator = LogReporterModuleConfigurator();
```

## Usage

### Basic Logging

Access the configured log reporter through dependency injection:

```dart
import 'package:log_reporter/log_reporter.dart';

// Get the configured log reporter from service locator
final logReporter = serviceLocator.get<LogReporter>();

// Log debug messages
logReporter.debug('User login attempt', tag: 'AuthService');

// Log errors with context
logReporter.error(
  'Failed to authenticate user',
  tag: 'AuthService',
  error: authException,
  stacktrace: stackTrace,
);
```

### Structured Logging with Tags

Use hierarchical tags to categorize and organize your logs:

```dart
// Service-level logging
logReporter.debug('Starting user data fetch', tag: 'UserService.fetchProfile');
logReporter.debug('Cache hit for user data', tag: 'UserService.cache');

// Network operation logging
logReporter.debug('API request started', tag: 'NetworkService.userAPI');
logReporter.error(
  'Network timeout occurred',
  tag: 'NetworkService.userAPI',
  error: timeoutException,
  stacktrace: stackTrace,
);

// Business logic logging
logReporter.debug('Payment processing started', tag: 'PaymentService.process');
logReporter.error(
  'Payment validation failed',
  tag: 'PaymentService.validate',
  error: validationError,
);
```

### Error Logging with Context

Always include relevant context when logging errors:

```dart
try {
  final result = await apiService.fetchUserData(userId);
  logReporter.debug('User data fetched successfully for ID: $userId', tag: 'UserService');
} catch (error, stackTrace) {
  logReporter.error(
    'Failed to fetch user data for ID: $userId',
    tag: 'UserService.fetchData',
    error: error,
    stacktrace: stackTrace,
  );
  rethrow;
}
```

## API Reference

### LogReporter Interface

The module provides a single `LogReporter` interface with two logging methods:

```dart
abstract class LogReporter {
  void debug(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stacktrace,
  });

  void error(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stacktrace,
  });
}
```

#### Parameters

- `message`: The log message to record
- `tag`: Optional hierarchical tag for categorizing logs (e.g., 'NetworkService.fetchUserProfile')
- `error`: Optional error object associated with the log entry
- `stacktrace`: Optional stack trace for debugging (recommended for error logs)

## Key Concepts

### Automatic Configuration

The module automatically configures logging to multiple destinations through the module configurator. You don't need to manually set up individual loggers - just inject the `LogReporter` and use it.

### Message Formatting

All log messages are automatically formatted with tags when provided:
- Debug messages: `[tag] message`
- Error messages: `[tag] message` with error details

### Tag Hierarchies

Use dot notation for hierarchical tags to organize logs by service and operation:
```dart
'ServiceName.operationName'
'UserService.fetchProfile'
'NetworkService.retry'
'PaymentService.validate'
```

## Platform Support

| Platform | LogReporter |
|----------|-------------|
| Android  | ✅          |
| iOS      | ✅          |
| macOS    | ✅          |
| Web      | ✅          |

## Dependencies

- `firebase`: Firebase Crashlytics integration
- `logger`: Console logging functionality
- `module_injector`: Dependency injection framework

## Testing

The module includes comprehensive test coverage:

```bash
flutter test
```

### Testing with LogReporter

For unit testing, you can mock the LogReporter interface:

```dart
import 'package:log_reporter/log_reporter.dart';
import 'package:mockito/mockito.dart';

class MockLogReporter extends Mock implements LogReporter {}

void main() {
  test('should log user operations', () {
    final mockLogger = MockLogReporter();
    final userService = UserService(mockLogger);
    
    userService.loginUser('123');
    
    verify(mockLogger.debug('User login started for ID: 123', tag: 'UserService')).called(1);
  });
}
```

## Best Practices

1. **Use Descriptive Tags**:
   - Use hierarchical naming (e.g., 'NetworkService.fetchUserProfile')
   - Avoid generic tags like 'Error' or 'Debug'
   - Be consistent with tag naming conventions across your app

2. **Include Relevant Context**:
   - Add user IDs, request IDs, or other contextual information in messages
   - Include relevant data that helps with debugging
   - Balance verbosity with usefulness

3. **Handle Error Information**:
   - Always include stack traces for error logs
   - Pass error objects when available for detailed error tracking
   - Use appropriate log levels (debug vs error)

4. **Structure Your Logging**:
   - Log at service boundaries (start/end of operations)
   - Log important state changes
   - Log all error conditions with sufficient context

## Contributing

This module follows the workspace development patterns. Ensure all changes include appropriate tests and maintain backward compatibility.
