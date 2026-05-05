# Core Module

A foundational Flutter package providing essential utilities, extensions, and models for the Port-Rai application.

## Features

- **DateTime Extensions**: Date formatting, week numbers, month/year extraction
- **Duration Extensions**: Intuitive duration creation (`5.seconds`, `30.minutes`)
- **String Extensions**: Capitalization, null-safe operations, longest string finder
- **Mapper Abstractions**: Generic and bidirectional data mapping
- **Core Models**: App configuration, localization, build environment

## Quick Setup

Import in any workspace module:
```dart
import 'package:core/core.dart';
```

> **Note**: As a workspace module, `core` is automatically available to all other modules without manual dependency configuration.

## Usage Examples

### DateTime & Duration
```dart
// Date formatting
DateTime.now().toFormattedDate;        // "2025-10-07"
DateTime.now().toMonthAndYear;         // "October, 2025"

// Duration creation
final timeout = 30.seconds;
await Future.delayed(2.minutes);
```

### String Operations
```dart
"john".capitalize;                     // "John"
"  ".isBlank;                         // true
["short", "longer"].longestString;     // "longer"
```

### Data Mapping
```dart
class UserMapper extends Mapper<UserDto, User> {
  @override
  User map(UserDto dto) => User(id: dto.id, name: dto.name);
}
```

## Testing

```bash
flutter test
```

## Dependencies

- Flutter SDK ^3.9.2
- collection, equatable, intl

---

Part of the Port-Rai modular architecture.
