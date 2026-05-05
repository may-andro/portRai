# Error Reporter

A comprehensive error reporting and handling solution for Flutter applications that provides multiple error handling strategies with blacklisting and fatal error management.

## Features

- **Error Reporting Interface**: Abstract error reporting interface for flexible backend implementation
- **Blacklist Error Filtering**: Automatically filter out unwanted errors from being reported
- **Fatal Error Handling**: Special handling for critical application errors with custom handlers
- **Global Error Handler**: Centralized error handling for the entire application
- **Type Safety**: Generic error reporting that maintains type safety with AppException types
- **Module Configuration**: Easy integration with dependency injection systems
- **Automatic Initialization**: Built-in setup and configuration management

## Getting Started

### Installation

This module is part of the workspace and can be imported directly:

```dart
import 'package:error_reporter/error_reporter.dart';
```

## Usage

### Basic Setup

Configure the error reporter module in your application:

```dart
import 'package:error_reporter/error_reporter.dart';

// Configure the module with Firebase support
final configurator = ErrorReporterModuleConfigurator(
  isFirebaseEnabled: true, // Set to false if Firebase is not available
);

// Register with your service locator
await configurator.registerDependencies(serviceLocator);
await configurator.postDependenciesSetup(serviceLocator);
```

### Error Reporting

```dart
// Get the error reporter instance
final errorReporter = serviceLocator.get<ErrorReporter>();

// Report application exceptions
try {
  // Your code that might throw an exception
  await someRiskyOperation();
} catch (exception, stackTrace) {
  await errorReporter.reportError(
    exception: exception,
    stackTrace: stackTrace,
    tag: 'user_action', // Optional tag for categorization
  );
}

// Report with custom tags for better categorization
await errorReporter.reportError(
  exception: NetworkException('Connection failed'),
  stackTrace: StackTrace.current,
  tag: 'network_error',
);
```

### Blacklist Error Handling

Filter out specific errors that shouldn't be reported:

```dart
// Create a custom blacklist handler
class NetworkTimeoutBlacklistHandler extends BlacklistErrorHandler {
  @override
  bool isBlacklistError(Object error) {
    // Ignore network timeout errors
    return error.toString().contains('timeout') ||
           error.toString().contains('connection refused');
  }
}

class DevelopmentBlacklistHandler extends BlacklistErrorHandler {
  @override
  bool isBlacklistError(Object error) {
    // Ignore debug-only errors in development
    return error is AssertionError && kDebugMode;
  }
}

// Register the handlers
final blacklistController = serviceLocator.get<BlacklistErrorController>();
blacklistController.register(NetworkTimeoutBlacklistHandler());
blacklistController.register(DevelopmentBlacklistHandler());

// Check if an error should be blacklisted
if (blacklistController.isBlacklistedError(someError)) {
  // Error will be ignored
}
```

### Fatal Error Handling

Handle critical application errors with custom recovery strategies:

```dart
// Create a custom fatal error handler
class CrashRecoveryHandler extends FatalErrorHandler {
  @override
  Future<void> onFatalError(Object error) async {
    // Show crash screen to user
    await showCrashDialog();
    
    // Save current state
    await saveApplicationState();
    
    // Send critical error report
    await sendCriticalErrorReport(error);
  }
}

class StateRecoveryHandler extends FatalErrorHandler {
  @override
  Future<void> onFatalError(Object error) async {
    // Attempt to recover application state
    await clearCorruptedData();
    await resetToSafeState();
  }
}

// Register the handlers
final fatalController = serviceLocator.get<FatalErrorController>();
fatalController.register(CrashRecoveryHandler());
fatalController.register(StateRecoveryHandler());

// Check if an error is fatal
if (fatalController.isFatalError(someError)) {
  await fatalController.onFatalError(someError);
}
```

### Global Error Handler

Set up comprehensive global error handling for your application:

```dart
final errorReporter = serviceLocator.get<ErrorReporter>();

// Initialize the error reporter
await errorReporter.init();

// Set up global error handling for Flutter errors
FlutterError.onError = errorReporter.globalErrorHandler;

// Set up global error handling for async errors
PlatformDispatcher.instance.onError = (error, stack) {
  errorReporter.globalErrorHandler(error, stack);
  return true;
};

// Set up error handling for specific zones
runZonedGuarded(
  () => runApp(MyApp()),
  errorReporter.globalErrorHandler,
);
```

### Module Configuration

The error reporter module automatically configures all dependencies:

```dart
import 'package:error_reporter/error_reporter.dart';

// Add to your module configurators
final configurator = ErrorReporterModuleConfigurator(
  isFirebaseEnabled: true, // Enable backend error reporting integration
);
```

## Public API Reference

### ErrorReporter

Abstract interface for error reporting implementations.

```dart
abstract class ErrorReporter {
  Future<void> init();
  
  Future<void> reportError<T extends AppException>({
    required T exception,
    required StackTrace stackTrace,
    String? tag,
  });
  
  void Function(Object, StackTrace) get globalErrorHandler;
}
```

### BlacklistErrorController

Controller for managing blacklist error handlers.

```dart
class BlacklistErrorController {
  void register(BlacklistErrorHandler handler);
  List<BlacklistErrorHandler> get registeredHandlers;
  bool isBlacklistedError(Object error);
}
```

### BlacklistErrorHandler

Abstract handler for implementing custom blacklist logic.

```dart
abstract class BlacklistErrorHandler {
  bool isBlacklistError(Object error);
}
```

### FatalErrorController

Controller for managing fatal error handlers.

```dart
class FatalErrorController {
  void register(FatalErrorHandler handler);
  List<FatalErrorHandler> get registeredHandlers;
  bool isFatalError(Object error);
  Future<void> onFatalError(Object error);
}
```

### FatalErrorHandler

Abstract handler for implementing custom fatal error handling.

```dart
abstract class FatalErrorHandler {
  Future<void> onFatalError(Object error);
}
```

### ErrorReporterModuleConfigurator

Module configurator for dependency injection setup.

```dart
class ErrorReporterModuleConfigurator implements ModuleConfigurator {
  ErrorReporterModuleConfigurator(bool isFirebaseEnabled);
  
  Future<void> registerDependencies(ServiceLocator serviceLocator);
  Future<void> postDependenciesSetup(ServiceLocator serviceLocator);
}
```

## Key Concepts

### Error Classification
The system automatically classifies errors into different categories:

- **AppException**: Application-specific exceptions that extend the base AppException type
- **Fatal Errors**: Critical errors that require immediate attention (Error types, FatalException)
- **Blacklisted Errors**: Errors that should be filtered out (development errors, known issues)
- **Regular Errors**: Standard exceptions that should be reported

### Error Filtering
- Blacklisted errors are automatically detected and prevented from being reported
- Custom blacklist handlers allow fine-grained control over error filtering
- Multiple blacklist handlers can be registered for different error types

### Error Reporting Flow
1. Error occurs in application
2. Check if error is blacklisted → Skip if blacklisted
3. Check if error is fatal → Handle through fatal error controllers
4. Report error through configured error reporter
5. Apply optional tags for categorization

## Handler Types

| Handler Type | Purpose | Use Case |
|--------------|---------|----------|
| BlacklistErrorHandler | Filter unwanted errors | Development errors, known issues |
| FatalErrorHandler | Handle critical errors | App crashes, data corruption |
| ErrorReporter | Report errors to backend | External error reporting services |

## Platform Support

| Platform | Error Reporting | Fatal Handling | Blacklisting |
|----------|----------------|----------------|--------------|
| Android  | ✅             | ✅             | ✅           |
| iOS      | ✅             | ✅             | ✅           |
| macOS    | ✅             | ✅             | ✅           |
| Web      | ✅             | ✅             | ✅           |

## Dependencies

- `core`: Core application utilities and exceptions
- `firebase`: Firebase integration for backend error reporting  
- `log_reporter`: Local logging functionality
- `module_injector`: Dependency injection framework
- `meta`: Metadata annotations for better code analysis

## Testing

The module includes comprehensive test coverage:

```bash
flutter test
```

## Best Practices

1. **Implement Custom Handlers**:
   - Create specific BlacklistErrorHandler implementations for your error types
   - Implement FatalErrorHandler for graceful error recovery
   - Use the ErrorReporter interface through dependency injection

2. **Configure Error Classification**:
   - Use specific AppException types for better categorization
   - Apply meaningful tags to error reports
   - Handle fatal errors with appropriate recovery strategies

3. **Configure Blacklisting Wisely**:
   - Filter out development-only errors
   - Blacklist known issues that don't require immediate attention
   - Avoid over-filtering important error information

4. **Handle Fatal Errors Gracefully**:
   - Implement user-friendly crash recovery
   - Save critical application state
   - Provide clear communication to users

5. **Error Handling Hierarchy**:
   - Set up global error handlers as safety nets
   - Use zone-based error handling for specific app sections
   - Implement try-catch blocks for expected error scenarios

## Contributing

This module follows the workspace development patterns. Ensure all changes include appropriate tests and maintain backward compatibility.
