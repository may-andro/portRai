# GitHub Copilot Instructions

## Testing Conventions

### Test naming
All test names **must** follow the `should ... when ...` pattern:

```dart
// ✅ Correct
test('should log debug message when onChange is called', () { ... });
test('should call onError when use case throws', () { ... });

// ❌ Wrong
test('logs debug message', () { ... });
test('onChange delegates to logReporter', () { ... });
```

### Shared mocks
Each mock class lives in its own file under `test/mock/`, named `mock_<class>.dart`. Never define local `_MockX` classes inside individual test files.

```
test/
  mock/
    mock_log_reporter.dart   ← class MockLogReporter extends Mock implements LogReporter {}
    mock_my_service.dart     ← class MockMyService extends Mock implements MyService {}
```

Import only the mock files you need:
```dart
import '../../mock/mock_log_reporter.dart';
```
