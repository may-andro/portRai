# Cache

Base classes for caching typed values in memory, in key-value storage (SharedPreferences) or in a
SQLite table, each with an optional time-to-live.

## Features

- `MemoryCache<T>`: a single value held in memory for the lifetime of the isolate
- `KeyValueCache<T>`: a single value stored as JSON in SharedPreferences
- `DBCache<T>`: many records stored in a SQLite table, with equality queries, upserts by primary
  key, batched writes and schema migrations
- Optional time-to-live per cache; expired entries are removed when they are read
- A `watch()` stream on every cache type that emits after each write and delete

## Getting Started

### Installation

The package is part of the workspace:

```yaml
dependencies:
  cache: any
```

```dart
import 'package:cache/cache.dart';
```

### Module Configuration

`CacheModuleConfigurator` implements `ModuleConfigurator` from
[module_injector](../module_injector/README.md). It registers no dependencies; add it to the
app's list of module configurators:

```dart
const CacheModuleConfigurator(),
```

## Usage

### Memory Cache

`MemoryCache` is not abstract, so it can be used directly or subclassed to set a time-to-live.

```dart
class SettingsMemoryCache extends MemoryCache<Settings> {
  @override
  Duration get timeToLive => const Duration(minutes: 15);
}

final cache = SettingsMemoryCache();
cache.put(settings);
final Settings? cached = cache.get(); // null when empty or expired
cache.delete();

final simpleCache = MemoryCache<String>()..put('value');
```

### Key-Value Cache

A subclass passes the storage key to the constructor and converts the value to and from a JSON
map. The map is stored as a JSON string under that key.

```dart
class SettingsCache extends KeyValueCache<Settings> {
  SettingsCache() : super('settings');

  @override
  Settings deserializeValue(Map<String, dynamic> map) => Settings.fromJson(map);

  @override
  Map<String, dynamic> serializeValue(Settings value) => value.toJson();

  @override
  Duration get timeToLive => const Duration(days: 30);
}

final cache = SettingsCache();
await cache.put(settings);
final Settings? cached = await cache.get();
await cache.delete();
```

### Database Cache

A subclass describes the table and converts each record to and from a map of column values.

```dart
class ItemCache extends DBCache<Item> {
  @override
  String get dbName => 'item_cache';

  @override
  String get tableName => 'items';

  @override
  int get tableVersion => 1;

  @override
  List<DbColumnDefinition> get columns => const [
    DbColumnDefinition(name: 'id', type: DbColumnType.integer, nullable: false),
    DbColumnDefinition(name: 'name', nullable: false),
  ];

  @override
  List<String> get primaryKeyColumns => const ['id'];

  @override
  Map<String, dynamic> serialize(Item model) => {'id': model.id, 'name': model.name};

  @override
  Item deserialize(Map<String, dynamic> map) =>
      Item(id: map['id'] as int, name: map['name'] as String);

  @override
  Duration get timeToLive => const Duration(hours: 24);
}

final cache = ItemCache();
await cache.put(Item(id: 1, name: 'First'));
// Stored in one transaction: all records or none.
await cache.putAll([Item(id: 2, name: 'Second'), Item(id: 3, name: 'Third')]);

final List<Item> all = await cache.getAll();
final List<Item> named = await cache.query(conditions: {'name': 'Second'});
final Item? one = await cache.get(conditions: {'id': 1});

await cache.delete({'id': 1});
await cache.deleteAll();
```

### Watching Changes

```dart
memoryCache.watch().listen((Settings? value) {}); // null after delete()
keyValueCache.watch().listen((Settings? value) {}); // null after delete()
itemCache.watch(conditions: {'id': 1}).listen((DbCacheEvent<Item> event) {
  // event.deleted is true for deletes, which are always forwarded.
});
```

## API Reference

### MemoryCache\<T\>

| Member | Description |
|--------|-------------|
| `T? get()` | Returns the value, or `null` when empty or expired (an expired value is deleted) |
| `void put(T model)` | Stores the value and the current timestamp |
| `void delete()` | Clears the value |
| `Stream<T?> watch()` | Broadcast stream of the value after each `put` and `null` after each `delete` |

### KeyValueCache\<T\>

Constructor: `KeyValueCache(String cacheKey)`. The value is stored under `cacheKey` and its write
time under `<cacheKey>.expiration`.

| Member | Description |
|--------|-------------|
| `T deserializeValue(Map<String, dynamic> map)` | Required: builds the value from the stored JSON map |
| `Map<String, dynamic> serializeValue(T value)` | Required: converts the value to a JSON map |
| `Future<T?> get()` | Returns the value, or `null` when absent or expired (an expired value is deleted) |
| `Future<bool> put(T value)` | Stores the value and the current timestamp |
| `Future<bool> delete()` | Removes the value and its timestamp |
| `Stream<T?> watch()` | Broadcast stream of the value after each `put` and `null` after each `delete` |

### DBCache\<T\>

| Member | Description |
|--------|-------------|
| `String get dbName` | Required: database file name, without extension |
| `String get tableName` | Required: table name |
| `int get tableVersion` | Required: schema version; raise it when the columns change |
| `List<DbColumnDefinition> get columns` | Required: the table's columns |
| `List<String> get primaryKeyColumns` | Columns of the primary key; defaults to none. With a key, writes replace the record with the same key |
| `Map<int, DbMigration> get migrations` | Migration steps keyed by the version they migrate to; defaults to none |
| `Map<String, dynamic> serialize(T model)` | Required: converts a model to column values |
| `T deserialize(Map<String, dynamic> map)` | Required: builds a model from column values |
| `Future<void> put(T model)` | Inserts or replaces one record |
| `Future<void> putAll(Iterable<T> models)` | Inserts or replaces all records in one transaction; does nothing for an empty list |
| `Future<List<T>> getAll()` | Returns every non-expired record |
| `Future<List<T>> query({Map<String, Object?> conditions})` | Returns non-expired records whose columns equal every condition |
| `Future<T?> get({Map<String, Object?> conditions})` | Returns the first matching record, or `null` when none matches or it has expired |
| `Future<void> delete(Map<String, Object?> conditions)` | Deletes every matching record |
| `Future<void> deleteAll()` | Deletes every record |
| `Stream<DbCacheEvent<T>> watch({Map<String, Object?> conditions})` | Emits each matching non-expired write, and every delete |

Supporting types exported with `DBCache`:

- `DbColumnDefinition({required String name, DbColumnType type = DbColumnType.text, bool nullable = true})`
- `DbColumnType`: `integer`, `real`, `text`, `blob`
- `DbMigration`: `List<Map<String, dynamic>> Function(List<Map<String, dynamic>> records)`
- `DbCacheEvent<T>`: `value` (`null` for deletes) and `deleted`
- `DBNotInitialisedException`: thrown by any `DBCache` call when the database fails to open;
  `cause` holds the original error, and the next call retries opening it

### Time-to-Live

Each cache overrides `Duration get timeToLive`. The default, `Duration.zero`, means entries never
expire. An entry is expired when its write time plus `timeToLive` is in the past.

- `MemoryCache` and `KeyValueCache` delete an expired value on `get()` and return `null`.
- `DBCache` stores each record's write time in an extra `cachedTimestamp` column, added to the
  table automatically. `getAll()` and `query()` leave expired records out and delete them without
  waiting; `get()` deletes an expired match and returns `null`.

### Initialization

`KeyValueCache` and `DBCache` open their storage on the first call and share that one operation
between concurrent callers. If opening fails, the next call tries again.

### Schema Migrations

When `tableVersion` increases:

- With no `migrations`, the table is dropped and recreated empty.
- Otherwise every record is read, passed through each migration step whose version is above the
  old version and at most the new one, in ascending order, and written into the recreated table.

```dart
@override
Map<int, DbMigration> get migrations => {
  2: (records) => records.map((record) => {...record, 'count': 0}).toList(),
};
```

## Platform Support

| Platform | MemoryCache | KeyValueCache | DBCache |
|----------|-------------|---------------|---------|
| Android  | Yes         | Yes           | Yes     |
| iOS      | Yes         | Yes           | Yes     |
| macOS    | Yes         | Yes           | Yes     |
| Web      | Yes         | Yes           | Yes     |

On native platforms, `DBCache` opens `<dbName>.db` in the sqflite databases directory. On the web
it uses the `sqflite_common_ffi_web` database factory; the app's web build needs the files
generated by `dart run sqflite_common_ffi_web:setup`.

## Dependencies

| Package | Purpose |
|---------|---------|
| `shared_preferences` | Storage behind `KeyValueCache` |
| `sqflite` | SQLite storage behind `DBCache` |
| `sqflite_common_ffi_web` | SQLite database factory for the web |
| `module_injector` | `ModuleConfigurator` interface for `CacheModuleConfigurator` |
| `meta` | `@visibleForTesting` and `@protected` annotations |

## Testing

```bash
melos run test --scope=cache
```

Or from `layer/cache`:

```bash
flutter test
```

The tests cover `MemoryCache`, `KeyValueCache` (with an in-memory storage adapter) and `DBCache`
(against SQLite through the `sqflite_common_ffi` database factory). The package exports no test
helpers.
