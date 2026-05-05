# Use Case Module

A Flutter package that provides base classes and utilities for implementing the Use Case pattern in clean architecture applications. This module helps organize business logic into discrete, testable units while providing error handling and interception capabilities.

## Features

- **Base Use Case Classes**: Abstract base classes for implementing use cases with and without parameters
- **Error Handling**: Built-in failure handling with typed error responses using Either pattern
- **Interceptor System**: Extensible interceptor system for cross-cutting concerns like logging, analytics, and monitoring
- **Dependency Injection**: Seamless integration with the module injector system
- **Type Safety**: Strongly typed inputs, outputs, and failures

## Getting Started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  use_case:
    path: ../use_case
```

## Usage

### Basic Use Case with Parameters

Create a use case that takes input parameters:

```dart
import 'package:use_case/use_case.dart';

class GetUserUseCase extends BaseUseCase<User, GetUserParams, UserFailure> {
  GetUserUseCase(this._repository);
  
  final UserRepository _repository;

  @override
  Future<Either<UserFailure, User>> execute(GetUserParams input) async {
    try {
      final user = await _repository.getUser(input.userId);
      return Right(user);
    } catch (e) {
      return Left(UserFailure(message: 'Failed to get user'));
    }
  }
}

class GetUserParams {
  const GetUserParams({required this.userId});
  final String userId;
}
```

### Use Case without Parameters

Create a use case that doesn't require input parameters:

```dart
import 'package:use_case/use_case.dart';

class GetCurrentUserUseCase extends BaseNoParamUseCase<User, UserFailure> {
  GetCurrentUserUseCase(this._repository);
  
  final UserRepository _repository;

  @override
  Future<Either<UserFailure, User>> execute() async {
    try {
      final user = await _repository.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(UserFailure(message: 'Failed to get current user'));
    }
  }
}
```

### Custom Failure Types

Define custom failure types by extending the base failure classes:

```dart
import 'package:use_case/use_case.dart';

class UserFailure extends BasicFailure {
  const UserFailure({super.message, super.cause});
}

class NetworkFailure extends BasicFailure {
  const NetworkFailure({super.message, super.cause});
}

// For use cases that don't fail, use NoFailure
class AlwaysSuccessUseCase extends BaseNoParamUseCase<String, NoFailure> {
  @override
  Future<Either<NoFailure, String>> execute() async {
    return const Right('Success');
  }
}
```

### Interceptors

Create custom interceptors to handle cross-cutting concerns:

```dart
import 'package:use_case/use_case.dart';

class LoggingInterceptor implements UseCaseInterceptor {
  @override
  void onCall<Param>(String tag, Param param) {
    print('UseCase called: $tag with params: $param');
  }

  @override
  void onSuccess<Output>(String tag, Output result) {
    print('UseCase succeeded: $tag with result: $result');
  }

  @override
  void onError(String tag, Object error, StackTrace? stackTrace) {
    print('UseCase failed: $tag with error: $error');
  }
}
```

### Module Configuration

Configure the module in your dependency injection setup:

```dart
import 'package:use_case/use_case.dart';

// The module automatically registers the UseCaseInterceptorController
// Register your interceptors:
final interceptorController = serviceLocator<UseCaseInterceptorController>();
interceptorController.register(LoggingInterceptor());
```

## API Reference

### Base Classes

- **`BaseUseCase<O, I, F>`**: Abstract base class for use cases that require input parameters
  - `O`: Output type
  - `I`: Input parameter type  
  - `F`: Failure type (must extend `Failure`)
  - `call(I input)`: Execute the use case with input parameters

- **`BaseNoParamUseCase<O, F>`**: Abstract base class for use cases without input parameters
  - `O`: Output type
  - `F`: Failure type (must extend `Failure`)
  - `call()`: Execute the use case without parameters

### Failure Types

- **`Failure`**: Base interface for all failures
- **`BasicFailure`**: Abstract base class providing message and cause properties
- **`NoFailure`**: Used for use cases that cannot fail
- **`UnknownFailure`**: Generic failure type for unexpected errors

### Interceptor System

- **`UseCaseInterceptor`**: Interface for implementing custom interceptors
  - `onCall<Param>(String tag, Param param)`: Called when use case starts
  - `onSuccess<Output>(String tag, Output result)`: Called on successful completion
  - `onError(String tag, Object error, StackTrace? stackTrace)`: Called on failure

- **`UseCaseInterceptorController`**: Manages interceptor registration
  - `register(UseCaseInterceptor interceptor)`: Register a new interceptor

### Module Configuration

- **`UseCaseModuleConfigurator`**: Handles dependency injection setup for the module

## Dependencies

This package depends on:
- `either_dart`: For functional error handling with Either type
- `equatable`: For value equality in failure types
- `meta`: For annotations like `@protected`
- `module_injector`: For dependency injection integration

## Best Practices

1. **Single Responsibility**: Each use case should handle one specific business operation
2. **Error Handling**: Always handle potential failures and return appropriate failure types
3. **Testability**: Use dependency injection to make use cases easily testable
4. **Type Safety**: Define specific failure types for different error scenarios
5. **Interceptors**: Use interceptors for logging, analytics, and other cross-cutting concerns
