import 'dart:async';

import 'package:cache/src/adapter/db_adapter.dart';
import 'package:cache/src/adapter/sqflite_db_adapter.dart';
import 'package:cache/src/cache.dart';
import 'package:meta/meta.dart';

const _cacheTimestampKey = 'cachedTimestamp';

/// Thrown when the [DbAdapter] fails to initialise.
///
/// The [cause] holds the original exception for diagnostics.
class DBNotInitialisedException implements Exception {
  const DBNotInitialisedException({required this.cause});

  final Object cause;

  @override
  String toString() => 'DBNotInitialisedException: $cause';
}

/// Abstract base class for database-backed caches.
///
/// Extend this class and implement the required members to make any object
/// cacheable using the underlying database technology.
///
/// [SqfliteDbAdapter] is used as the underlying storage engine by default;
/// the [adapter] parameter exists only for injecting a test double inside the
/// `cache` package's own tests.
///
/// ### Example
/// ```dart
/// class ProductCache extends DBCache<Product> {
///   ProductCache();
///
///   @override String get dbName => 'product_cache';
///   @override String get tableName => 'products';
///   @override int get tableVersion => 1;
///
///   @override
///   List<DbColumnDefinition> get columns => [
///     const DbColumnDefinition(name: 'id'),
///     const DbColumnDefinition(name: 'name'),
///   ];
///
///   @override List<String> get primaryKeyColumns => ['id'];
///
///   @override
///   Map<String, dynamic> serialize(Product m) => {'id': m.id, 'name': m.name};
///
///   @override
///   Product deserialize(Map<String, dynamic> map) =>
///       Product(id: map['id'] as String, name: map['name'] as String);
/// }
/// ```
abstract class DBCache<T> extends Cache {
  DBCache({@visibleForTesting DbAdapter? adapter})
    : _adapter = adapter ?? SqfliteDbAdapter();

  final DbAdapter _adapter;

  // Caches the initialization future so concurrent callers await the same
  // operation instead of each starting their own.
  Future<void>? _initFuture;
  int _cacheTimestamp = 0;

  // ── Subclass contract ──────────────────────────────────────────────────────

  /// Name of the database (or file / directory) that holds this table.
  String get dbName;

  /// Name of the table (or equivalent collection / box) inside the database.
  String get tableName;

  /// Schema version. Increment this value whenever the column layout changes
  /// to trigger a migration in the adapter.
  int get tableVersion;

  /// Column definitions for this table, **excluding** the internally managed
  /// cache-timestamp column (added automatically by [DBCache]).
  List<DbColumnDefinition> get columns;

  /// Column names that form the primary / composite key.
  ///
  /// When non-empty, [put] will replace any existing record whose values for
  /// these columns match the new record (upsert semantics).
  /// Defaults to an empty list (each [put] appends a new row).
  List<String> get primaryKeyColumns => const [];

  /// Migration steps applied when [tableVersion] is incremented.
  ///
  /// Key is the version being migrated **to**; value is a function that
  /// transforms all stored records from the previous version.
  ///
  /// ### Example — add a default `stock` field in v2
  /// ```dart
  /// @override
  /// Map<int, DbMigration> get migrations => {
  ///   2: (records) => records
  ///       .map((r) => {...r, 'stock': 0})
  ///       .toList(),
  /// };
  /// ```
  Map<int, DbMigration> get migrations => const {};

  /// Converts a domain model [T] into a plain `Map<String, dynamic>` that
  /// can be stored by the [DbAdapter].
  Map<String, dynamic> serialize(T model);

  /// Converts a plain `Map<String, dynamic>` read from the [DbAdapter] back
  /// into a domain model [T].
  T deserialize(Map<String, dynamic> map);

  // ── Cache ──────────────────────────────────────────────────────────────────

  @override
  int get lastCachedTimestamp => _cacheTimestamp;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Inserts or replaces [model] in the cache and records the current
  /// timestamp for TTL checks.
  Future<void> put(T model) async {
    await _ensureInitialized();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final values = {...serialize(model), _cacheTimestampKey: timestamp};
    await _adapter.upsert(values);
    _cacheTimestamp = timestamp;
  }

  /// Returns every non-expired item currently in the cache.
  ///
  /// Expired items are removed in the background.
  Future<List<T>> getAll() => query();

  /// Returns all non-expired items that match every entry in [conditions]
  /// (AND equality semantics).
  ///
  /// When [conditions] is empty all items are returned (equivalent to
  /// [getAll]).
  Future<List<T>> query({Map<String, Object?> conditions = const {}}) async {
    await _ensureInitialized();
    final records = conditions.isEmpty
        ? await _adapter.findAll()
        : await _adapter.findBy(conditions);
    return _filterAndCleanExpired(records);
  }

  /// Returns the first non-expired item matching [conditions], or `null`.
  ///
  /// When [conditions] is empty the first item in the table is returned.
  /// Expired matches are removed and `null` is returned in their place.
  Future<T?> get({Map<String, Object?> conditions = const {}}) async {
    await _ensureInitialized();

    final record = conditions.isEmpty
        ? (await _adapter.findAll()).firstOrNull
        : await _adapter.findOneBy(conditions);

    if (record == null) return null;

    if (_isCachedItemValid(record)) {
      return deserialize(record);
    }

    if (record.containsKey(_cacheTimestampKey)) {
      await _adapter.deleteBy({_cacheTimestampKey: record[_cacheTimestampKey]});
    }
    return null;
  }

  /// Deletes all records matching [conditions].
  Future<void> delete(Map<String, Object?> conditions) async {
    await _ensureInitialized();
    await _adapter.deleteBy(conditions);
  }

  /// Removes every item from the cache.
  Future<void> deleteAll() async {
    await _ensureInitialized();
    await _adapter.clear();
  }

  /// Returns a broadcast stream that emits a [DbCacheEvent] whenever an item
  /// is inserted, updated, or deleted in the underlying table.
  ///
  /// When [conditions] is non-empty only events whose record matches every
  /// entry (AND equality semantics) are emitted.
  /// Deletion events are always forwarded because the original record values
  /// are no longer available for filtering.
  Stream<DbCacheEvent<T>> watch({
    Map<String, Object?> conditions = const {},
  }) async* {
    await _ensureInitialized();
    yield* _adapter
        .watch(conditions: conditions)
        .where((event) {
          if (event.deleted) return true;
          final record = event.value;
          if (record == null) return false;
          return _isCachedItemValid(record);
        })
        .map((event) {
          if (event.deleted) {
            return DbCacheEvent<T>(value: null, deleted: true);
          }
          return DbCacheEvent<T>(
            value: deserialize(event.value!),
            deleted: false,
          );
        });
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  // Returns the single shared initialization future, starting it on first call.
  // If initialization fails the future is cleared so the next call retries.
  Future<void> _ensureInitialized() => _initFuture ??= _initialize();

  Future<void> _initialize() async {
    try {
      await _adapter.initialize(
        DbTableSchema(
          dbName: dbName,
          tableName: tableName,
          version: tableVersion,
          columns: [
            ...columns,
            const DbColumnDefinition(
              name: _cacheTimestampKey,
              type: DbColumnType.integer,
              nullable: false,
            ),
          ],
          primaryKeyColumns: primaryKeyColumns,
          migrations: migrations,
        ),
      );
    } catch (e) {
      _initFuture = null; // allow retry on next call
      throw DBNotInitialisedException(cause: e);
    }
  }

  List<T> _filterAndCleanExpired(List<Map<String, dynamic>> records) {
    final valid = <T>[];
    final expired = <Map<String, dynamic>>[];

    for (final record in records) {
      final timestamp = _timestampOf(record);
      if (timestamp != null && _isTimestampValid(timestamp)) {
        _cacheTimestamp = timestamp;
        valid.add(deserialize(record));
      } else {
        expired.add(record);
      }
    }

    _deleteExpiredEntries(expired);
    return valid;
  }

  bool _isCachedItemValid(Map<String, dynamic> record) {
    final timestamp = _timestampOf(record);
    if (timestamp == null) return false;
    if (!_isTimestampValid(timestamp)) return false;
    _cacheTimestamp = timestamp;
    return true;
  }

  /// Returns the cached timestamp stored inside [record], or `null` if absent.
  int? _timestampOf(Map<String, dynamic> record) {
    final raw = record[_cacheTimestampKey];
    return raw is int ? raw : null;
  }

  /// Returns `true` when [timestamp] has not yet exceeded the [timeToLive].
  bool _isTimestampValid(int timestamp) {
    final allowedMs = timeToLive.inMilliseconds;
    if (allowedMs == 0) return true; // no TTL set → never expires
    return timestamp + allowedMs >= DateTime.now().millisecondsSinceEpoch;
  }

  void _deleteExpiredEntries(List<Map<String, dynamic>> expiredRecords) {
    for (final record in expiredRecords) {
      final timestamp = _timestampOf(record);
      if (timestamp != null) {
        // Fire-and-forget: expired entries are cleaned up in the background.
        unawaited(_adapter.deleteBy({_cacheTimestampKey: timestamp}));
      }
    }
  }
}
