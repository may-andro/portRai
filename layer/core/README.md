# Core

A foundational Flutter package providing essential utilities, extensions, and models for the Port-Rai application. As a workspace module, it is part of the Port-Rai modular architecture and is automatically available to other workspace packages.

## Features

- **DateTime Extensions**: Date formatting, week numbers, month/year extraction
- **Duration Extensions**: Intuitive duration creation (`5.seconds`, `30.minutes`)
- **String Extensions**: Capitalization, null-safe operations, longest string finder
- **Mapper Abstractions**: Generic and bidirectional data mapping
- **Core Models**: App configuration, localization, build environment

## Getting Started

### Installation

This module is part of the workspace and can be added as a workspace dependency:

```yaml
dependencies:
  core: any
```

Import in any workspace module:

```dart
import 'package:core/core.dart';
```

> **Note**: As a workspace module, `core` is automatically available to all other modules without manual dependency configuration.

## Usage

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

## Key Concepts

### DateTime Extensions

Date formatting, week numbers, month/year extraction

### Duration Extensions

Intuitive duration creation (`5.seconds`, `30.minutes`)

### String Extensions

Capitalization, null-safe operations, longest string finder

### Mapper Abstractions

Generic and bidirectional data mapping

### Core Models

App configuration, localization, build environment

## Dependencies

- Flutter SDK ^3.9.2
- `collection`: Collection utilities used by shared helpers and models
- `equatable`: Value equality support for shared model types
- `intl`: Date and localization formatting utilities

## Testing

```bash
flutter test
```
