# Core

Shared extensions, mapper interfaces, models and exception types used by the other workspace packages. It also re-exports `package:collection` and `package:intl`.

## Features

- `DateTime` formatting getters, ISO week number, and `String` to `DateTime` parsing
- `num` to `Duration` getters (`5.seconds`, `30.minutes`)
- `String` and `String?` helpers for capitalization, blank and null checks
- Dot-separated version string comparison
- `Mapper` and `BiMapper` interfaces for data mapping
- `AppConfig`, `AppLocale`, `BuildConfig` and `BuildEnvironment` models
- `AppException` base type with `NullException` and `FatalException`

## Getting Started

### Installation

Add the workspace package as a dependency:

```yaml
dependencies:
  core: any
```

```dart
import 'package:core/core.dart';
```

### Module Configuration

This layer has no `ModuleConfigurator`; import it and use its types directly.

## Usage

### Dates and Durations

```dart
final date = DateTime(2025, 10, 7);
date.toFormattedDate; // "2025-10-07"
date.toMonthAndYear; // "October, 2025"
date.weekNumber; // 41

'2025-10-07'.toFormattedDate; // DateTime(2025, 10, 7)

final timeout = 30.seconds;
await Future<void>.delayed(2.minutes);
```

### Strings

```dart
'john'.capitalize; // "John"
'  '.isBlank; // true

String? value;
value.isNullOrBlank; // true
value.orEmpty(); // ""

['short', 'longer'].longestString; // "longer"
```

### Versions

```dart
'1.2'.compareVersion('1.2.0'); // 0
'1.9.0'.isLowerVersionThan('1.10.0'); // true
```

### Data Mapping

```dart
class ItemMapper implements Mapper<ItemDto, Item> {
  @override
  Item map(ItemDto from) => Item(id: from.id, name: from.name);
}

class ItemBiMapper implements BiMapper<ItemDto, Item> {
  @override
  Item to(ItemDto from) => Item(id: from.id, name: from.name);

  @override
  ItemDto from(Item from) => ItemDto(id: from.id, name: from.name);
}
```

### Build Environment

```dart
final environment = BuildEnvironment.buildEnvironment;
final config = BuildConfig(buildEnvironment: environment);
```

## API Reference

### Extensions

| Extension | On | Members |
| --- | --- | --- |
| `DateTimeFormatting` | `DateTime` | `toFormattedDate` (`yyyy-MM-dd`), `toFormattedDateTime` (`dd MMM yyyy, hh:mm a`), `toFullDateTime` (`EEEE, MMMM d, yyyy H:m`), `toFullDateWithoutTime` (`EEEE, MMMM d, yyyy`), `toMonthAndYear` (`MMMM, yyyy`), `toYear`, `year`, `month` (`MM`), `weekNumber` (ISO 8601) |
| `StringDateFormatting` | `String` | `toFormattedDate`, `toMonthAndYear`, `toFormattedDateTime`, `toFullDateTime`: parse the matching `DateTimeFormatting` format back into a `DateTime` |
| `NumDurationExtensions` | `num` | `microseconds`, `milliseconds`, `seconds`, `minutes`, `hours`, `days` |
| `StringMapper` | `String` | `capitalize`, `isBlank`, `isNotBlank` |
| `NullableStringIsNullOrEmptyExtension` | `String?` | `isNull`, `isNonNull`, `isNullOrEmpty`, `isNotNullOrEmpty`, `isNullOrBlank`, `isNotNullOrBlank`, `orEmpty()` |
| `StringsExtension` | `List<String>` | `longestString` (first longest entry, `''` for an empty list) |
| `VersionComparisonExtension` | `String` | `compareVersion(String other)`, `isLowerVersionThan(String other)`. Missing segments count as `0`; non-numeric suffixes on a segment are ignored. |
| `AppLocaleExtension` | `AppLocale` | `locale` (Flutter `Locale`) |
| `LocaleExtension` | `Locale` | `appLocale` |

### Mappers

- `Mapper<From, To>`: `To map(From from)`
- `BiMapper<From, To>`: `To to(From from)` and `From from(To from)`

### Models

- `AppConfig`: abstract `const` base class with no fields; each app defines a subclass with its own fields.
- `AppLocale(String languageCode)`: value equality on `languageCode`, `AppLocale.fallback()` (`en`), `AppLocale.fromJson` and `toJson` using the `languageCode` key.
- `BuildEnvironment`: `staging` or `prod`. `BuildEnvironment.buildEnvironment` reads the `build_env` compile-time define (`--dart-define=build_env=staging`) and falls back to `prod` when it is missing or unknown. Flags: `isFirebaseEnabled` (prod), `isFeatureFlagCached`, `isRemoteLoggingEnabled`, `isSplashDescriptive`, `isDevMenuEnabled`, `debugShowCheckedModeBanner` (staging).
- `BuildConfig({required BuildEnvironment buildEnvironment})`

### Exceptions

- `AppException`: base `Exception` type that custom exceptions implement.
- `NullException` and `FatalException`: implement `AppException`.

## Dependencies

- `collection`: `firstWhereOrNull` in `BuildEnvironment`; re-exported
- `equatable`: declared in `pubspec.yaml`; not imported by `lib/`
- `intl`: `DateFormat` in the date extensions; re-exported

## Testing

```bash
melos run test --scope=core
```

Or from `layer/core`:

```bash
flutter test
```
