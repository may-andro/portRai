# Cache Module

A comprehensive caching solution for Flutter applications that provides multiple caching strategies with automatic expiration management.

## Features

- **Multiple Cache Types**: Support for in-memory, key-value (SharedPreferences), and database (SQLite) caching
- **Automatic Expiration**: Built-in time-to-live (TTL) support with automatic cleanup of expired data
- **Type Safety**: Generic implementations that maintain type safety across all cache operations
- **Cross-Platform**: Works on Android, iOS, macOS, and Web platforms
- **Flexible Storage**: Choose the appropriate cache type based on your data persistence needs
- **Serialization Support**: Automatic JSON serialization/deserialization for complex objects

## Cache Types

### 1. MemoryCache
Fast in-memory caching for temporary data that doesn't need to persist across app restarts.

**Best for**: Session data, computed values, frequently accessed temporary objects

### 2. KeyValueCache
Persistent key-value storage using SharedPreferences with automatic JSON serialization.

**Best for**: User preferences, settings, small data objects, authentication tokens

### 3. DBCache
SQLite-based caching for complex data structures and bulk operations.

**Best for**: Large datasets, complex queries, relational data, offline data storage

## Getting Started

### Installation

This module is part of the workspace and can be imported directly:

```dart
import 'package:cache/cache.dart';
```

## Usage

### Memory Cache

```dart
// Create a custom memory cache with expiration
class UserMemoryCache extends MemoryCache<User> {
  @override
  Duration get timeToLive => const Duration(minutes: 15);
}

// Usage
final userCache = UserMemoryCache();

// Store data
userCache.put(User(id: 1, name: 'John Doe'));

// Retrieve data
final user = userCache.get(); // Returns User or null if expired/not found

// Clear cache
userCache.delete();

// For simple cases without expiration, you can use MemoryCache directly
final simpleCache = MemoryCache<String>();
simpleCache.put('cached value');
```

### Key-Value Cache

```dart
class UserPreferencesCache extends KeyValueCache<UserPreferences> {
  UserPreferencesCache({super.adapter}) : super('user_preferences');

  @override
  UserPreferences deserializeValue(Map<String, dynamic> map) {
    return UserPreferences.fromJson(map);
  }

  @override
  Map<String, dynamic> serializeValue(UserPreferences value) {
    return value.toJson();
  }

  @override
  Duration get timeToLive => const Duration(days: 30);
}

// Usage — defaults to SharedPreferences under the hood
final prefsCache = UserPreferencesCache();
await prefsCache.put(UserPreferences(theme: 'dark', notifications: true));
final preferences = await prefsCache.get();
```

### Database Cache

```dart
class UserDBCache extends DBCache<User> {
  UserDBCache({super.adapter});

  @override
  String get dbName => 'user_cache';

  @override
  String get tableName => 'users';

  @override
  int get tableVersion => 1;

  @override
  List<DbColumnDefinition> get columns => [
    const DbColumnDefinition(name: 'id', nullable: false),
    const DbColumnDefinition(name: 'name', nullable: false),
    const DbColumnDefinition(name: 'email', nullable: false),
  ];

  @override
  List<String> get primaryKeyColumns => ['id'];

  @override
  Map<String, dynamic> serialize(User model) {
    return {
      'id': model.id,
      'name': model.name,
      'email': model.email,
    };
  }

  @override
  User deserialize(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
    );
  }

  @override
  Duration get timeToLive => const Duration(hours: 24);
}

// Usage — defaults to SQLite under the hood
final userCache = UserDBCache();
await userCache.put(User(id: 1, name: 'John', email: 'john@example.com'));
final users = await userCache.getAll();
final user = await userCache.get(conditions: {'id': 1});
```

### Module Configuration

The cache module automatically configures SharedPreferences dependency injection:

```dart
import 'package:cache/cache.dart';

// Add to your module configurators
final configurator = CacheModuleConfigurator();
```

## Key Concepts

### Time-to-Live (TTL)
All cache types support automatic expiration through the `timeToLive` property:

```dart
@override
Duration get timeToLive => const Duration(minutes: 30);
```

### Expiration Handling
- Expired data is automatically detected and removed when accessed
- The `isExpired` property checks if cached data has exceeded its TTL
- `lastCachedTimestamp` tracks when data was last stored

### Thread Safety
- MemoryCache: Thread-safe for single-isolate usage
- KeyValueCache: Thread-safe through the underlying adapter (SharedPreferences by default)
- DBCache: Thread-safe through SQLite transactions

## Platform Support

| Platform | MemoryCache | KeyValueCache | DBCache |
|----------|-------------|---------------|---------|
| Android  | ✅          | ✅            | ✅      |
| iOS      | ✅          | ✅            | ✅      |
| macOS    | ✅          | ✅            | ✅      |
| Web      | ✅          | ✅            | ✅      |

## Dependencies

- `shared_preferences`: Key-value persistent storage
- `sqflite`: SQLite database for mobile platforms
- `sqflite_common_ffi_web`: SQLite support for web platform
- `module_injector`: Dependency injection framework
- `core`: Core utilities and types

## Testing

The module includes comprehensive test coverage with mocked dependencies:

```bash
flutter test
```

## Best Practices

1. **Choose the Right Cache Type**:
   - Use MemoryCache for temporary, frequently accessed data
   - Use KeyValueCache for simple persistent data
   - Use DBCache for complex data with query requirements

2. **Set Appropriate TTL**:
   - Consider data freshness requirements
   - Balance between performance and data accuracy
   - Use longer TTL for static data, shorter for dynamic data

3. **Handle Null Returns**:
   - Always check for null returns from cache operations
   - Implement fallback data fetching strategies

4. **Error Handling**:
   - Catch `DBNotInitialisedException` for database operations
   - Implement retry logic for critical cache operations

## Contributing

This module follows the workspace development patterns. Ensure all changes include appropriate tests and maintain backward compatibility.
