# Remote

A REST client interface backed by [Dio](https://pub.dev/packages/dio), with retries, optional
request logging, and Dio errors mapped to a sealed `RemoteApiException` hierarchy.

## Features
- `RestApiService` interface with generic `get<T>` and `post<T>` methods that return the
  decoded response body.
- One shared `Dio` instance with a base URL and 10-second send and receive timeouts.
- Retries through `dio_smart_retry`'s `RetryInterceptor` with its default settings (3 retries,
  after 1, 3 and 5 seconds).
- Optional request and response logging through `pretty_dio_logger`.
- `DioException`s are rethrown as `RemoteApiException` subtypes; other errors are rethrown
  unchanged.

## Getting Started
### Installation

```yaml
dependencies:
  remote: any
```

```dart
import 'package:remote/remote.dart';
```

### Module Configuration
`RemoteModuleConfigurator` takes two positional arguments:

```dart
RemoteModuleConfigurator(
  bool isLoggingEnabled, // adds PrettyDioLogger with request headers and bodies
  String baseUrl,        // BaseOptions.baseUrl for every request
)
```

```dart
final configurators = <ModuleConfigurator>[
  RemoteModuleConfigurator(true, 'https://api.example.com'),
];

await ModuleInjectorController()
    .setUpDIGraph(configurators: configurators)
    .drain<void>();
```

`registerDependencies` registers `RestApiService` as a singleton. The `Dio` instance is not
registered, so its options and interceptors cannot be changed from outside the layer.

## Usage

```dart
class ItemRepository {
  ItemRepository(this._restApiService);

  final RestApiService _restApiService;

  Future<Map<String, dynamic>?> getItem(String id) {
    return _restApiService.get<Map<String, dynamic>>('/items/$id');
  }

  Future<List<dynamic>?> searchItems(String query) {
    return _restApiService.get<List<dynamic>>(
      '/items',
      queryParameters: {'q': query},
    );
  }
}

final repository = ItemRepository(serviceLocator.get<RestApiService>());
```

`post<T>` sends `queryParameters` in the URL; it has no request body parameter.

## API Reference

### RestApiService

```dart
abstract class RestApiService {
  Future<T?> get<T>(String path, {Map<String, dynamic>? queryParameters});

  Future<T?> post<T>(String path, {Map<String, dynamic>? queryParameters});
}
```

The registered implementation wraps `Dio.get` and `Dio.post` and returns `response.data`. It is
internal to the layer and not exported.

### RemoteModuleConfigurator
Implements `ModuleConfigurator`. All work happens in `registerDependencies`;
`preDependenciesSetup` and `postDependenciesSetup` do nothing.

## Exception Handling

All exceptions extend the sealed `RemoteApiException`, which implements `AppException` from
`core` and carries the original `cause` and `stackTrace`.

| Dio error | Exception |
|-----------|-----------|
| `connectionTimeout`, `sendTimeout`, `receiveTimeout` | `ApiConnectionTimeoutException` |
| `badResponse` with status 401 | `ApiAuthenticationException` |
| `badResponse` with status 400–499 (except 401) | `ApiClientException` |
| `badResponse` with status 500 and above | `ApiServerException` |
| `badResponse` with another status or no response | `ApiUnknownException` |
| Any other type (`connectionError`, `cancel`, `badCertificate`, `unknown`) | `ApiUnknownException` |

`ApiAuthenticationException`, `ApiClientException` and `ApiServerException` also expose
`errorMessage`. When the response has a status message, `errorMessage` is read from the
`message` field of the response body, which must then be a JSON object; otherwise it is an
empty string.

`ApiNetworkException` is part of the hierarchy but the Dio mapping never produces it.

```dart
try {
  await restApiService.get<Map<String, dynamic>>('/items/1');
} on ApiConnectionTimeoutException {
  // retry later
} on ApiAuthenticationException catch (e) {
  // e.errorMessage
} on RemoteApiException catch (e) {
  // e.cause, e.stackTrace
}
```

## Dependencies
- `dio`: HTTP client.
- `dio_smart_retry`: `RetryInterceptor`.
- `pretty_dio_logger`: request and response logging.
- `core`: `AppException`.
- `module_injector`: `ModuleConfigurator` and `ServiceLocator`.

## Testing

```bash
melos run test --scope=remote
```

Or, from `layer/remote`:

```bash
flutter test
```

The tests use `http_mock_adapter` to stub Dio responses and check the exception mapping for
`get` and `post`. The package exports no test fakes.
