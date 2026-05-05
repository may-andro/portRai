# Remote Module

A robust HTTP client service module for Flutter applications that provides a clean abstraction layer for REST API communications with comprehensive error handling and automatic retry capabilities.

## Features

- **Clean REST API Interface**: Simple abstraction over HTTP operations with type-safe responses
- **Comprehensive Error Handling**: Structured exception hierarchy for different API error scenarios
- **Automatic Retry Logic**: Built-in smart retry mechanism for failed requests
- **Request/Response Logging**: Optional pretty logging for debugging and development
- **Timeout Management**: Configurable connection, send, and receive timeouts
- **Type Safety**: Generic method signatures for type-safe API responses
- **Dependency Injection**: Seamless integration with the module injection system

## Architecture

The module is built on top of [Dio](https://pub.dev/packages/dio) and provides:

- **RestApiService**: Abstract interface defining HTTP operations
- **DioApiService**: Concrete implementation using Dio HTTP client
- **Exception System**: Comprehensive error handling with specific exception types
- **Module Configuration**: Automatic dependency injection setup

## Getting Started

### Installation

This module is part of the workspace and can be imported directly:

```dart
import 'package:remote/remote.dart';
```

## Usage

### Basic Setup

Configure the remote module in your application:

```dart
import 'package:remote/remote.dart';

// Configure the module with base URL and logging
final remoteConfigurator = RemoteModuleConfigurator(
  true, // Enable logging for development
  'https://api.example.com', // Your API base URL
);

// Add to your module configurators
await ModuleInjectorController().configure([remoteConfigurator]);
```

### Making API Calls

```dart
import 'package:remote/remote.dart';
import 'package:module_injector/module_injector.dart';

class UserRepository {
  late final RestApiService _apiService;

  UserRepository() {
    _apiService = ModuleInjectorController()
        .serviceLocator
        .get<RestApiService>();
  }

  // GET request example
  Future<User?> getUser(int userId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/users/$userId',
      );
      
      if (response != null) {
        return User.fromJson(response);
      }
      return null;
    } on RemoteApiException catch (e) {
      // Handle API-specific errors
      throw UserFetchException('Failed to fetch user: $e');
    }
  }

  // POST request example
  Future<User?> createUser(CreateUserRequest request) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/users',
        queryParameters: request.toJson(),
      );
      
      if (response != null) {
        return User.fromJson(response);
      }
      return null;
    } on ApiAuthenticationException {
      throw AuthenticationRequiredException();
    } on ApiClientException catch (e) {
      throw InvalidUserDataException(e.errorMessage);
    } on ApiServerException {
      throw ServerUnavailableException();
    }
  }

  // GET with query parameters
  Future<List<User>> getUsers({
    int? page,
    int? limit,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (search != null) queryParams['search'] = search;

    final response = await _apiService.get<List<dynamic>>(
      '/users',
      queryParameters: queryParams,
    );

    return response?.map((json) => User.fromJson(json)).toList() ?? [];
  }
}
```

## Exception Handling

The module provides a comprehensive exception hierarchy for different error scenarios:

### Exception Types

```dart
// Base exception class
sealed class RemoteApiException implements AppException

// Network-related errors
class ApiNetworkException extends RemoteApiException

// Authentication errors (HTTP 401)
class ApiAuthenticationException extends RemoteApiException

// Client errors (HTTP 4xx)
class ApiClientException extends RemoteApiException

// Server errors (HTTP 5xx) 
class ApiServerException extends RemoteApiException

// Connection timeout errors
class ApiConnectionTimeoutException extends RemoteApiException

// Unknown errors
class ApiUnknownException extends RemoteApiException
```

### Error Handling Examples

```dart
try {
  final user = await userRepository.getUser(123);
} on ApiAuthenticationException catch (e) {
  // Handle authentication failure
  navigationService.navigateToLogin();
} on ApiConnectionTimeoutException catch (e) {
  // Handle timeout
  showErrorMessage('Connection timeout. Please try again.');
} on ApiServerException catch (e) {
  // Handle server errors
  showErrorMessage('Server is temporarily unavailable.');
} on ApiClientException catch (e) {
  // Handle client errors (validation, not found, etc.)
  showErrorMessage('Error: ${e.errorMessage}');
} on RemoteApiException catch (e) {
  // Handle any other API errors
  showErrorMessage('An unexpected error occurred.');
}
```

## Configuration Options

### RemoteModuleConfigurator Parameters

```dart
RemoteModuleConfigurator(
  bool isLoggingEnabled, // Enable/disable request/response logging
  String baseUrl,        // Base URL for all API calls
)
```

### Default Configuration

The module automatically configures:
- **Connection Timeout**: 10 seconds
- **Send Timeout**: 10 seconds  
- **Receive Timeout**: 10 seconds
- **Automatic Retry**: Enabled with smart retry logic
- **Pretty Logging**: Optional (controlled by `isLoggingEnabled`)

## Advanced Usage

### Custom Headers

```dart
// Access the underlying Dio instance for advanced configuration
final dio = serviceLocator.get<Dio>();
dio.options.headers['Authorization'] = 'Bearer $token';
dio.options.headers['Content-Type'] = 'application/json';
```

### Interceptors

```dart
// Add custom interceptors during configuration
class CustomRemoteConfigurator extends RemoteModuleConfigurator {
  CustomRemoteConfigurator(super.isLoggingEnabled, super.baseUrl);

  @override
  FutureOr<void> registerDependencies(ServiceLocator serviceLocator) {
    super.registerDependencies(serviceLocator);
    
    final dio = serviceLocator.get<Dio>();
    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(CacheInterceptor());
  }
}
```

## Testing

The module includes comprehensive test coverage with HTTP mocking:

```dart
// Example test setup
late DioApiService dioApiService;
late DioAdapter dioAdapter;
late Dio dio;

setUp(() {
  dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
  dioAdapter = DioAdapter(dio: dio);
  dio.httpClientAdapter = dioAdapter;
  dioApiService = DioApiService(dio);
});

test('should return response when status code is 200', () async {
  const path = '/users/1';
  const response = {'id': 1, 'name': 'John Doe'};
  dioAdapter.onGet(path, (request) => request.reply(200, response));

  final result = await dioApiService.get<Map<String, dynamic>>(path);
  expect(result, equals(response));
});
```

Run tests with:
```bash
flutter test
```

## Dependencies

- **dio**: HTTP client for Dart/Flutter
- **dio_smart_retry**: Automatic retry functionality
- **pretty_dio_logger**: Request/response logging
- **module_injector**: Dependency injection framework
- **core**: Core utilities and types

## Best Practices

1. **Error Handling**: Always wrap API calls in try-catch blocks and handle specific exception types
2. **Type Safety**: Use generic types for API responses to maintain type safety
3. **Timeouts**: Configure appropriate timeouts based on your API characteristics
4. **Logging**: Enable logging in development, disable in production
5. **Authentication**: Handle authentication errors gracefully with automatic login redirects
6. **Retry Logic**: The built-in retry mechanism handles transient failures automatically
7. **Base URL**: Use environment-specific base URLs (dev, staging, production)

## Contributing

This module follows the workspace development patterns. Ensure all changes include appropriate tests and maintain backward compatibility.
