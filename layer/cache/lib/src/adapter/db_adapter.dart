/// Supported column types for a [DbTableSchema].
enum DbColumnType { integer, real, text, blob }

/// Describes a single column in a database table.
class DbColumnDefinition {
  const DbColumnDefinition({
    required this.name,
    this.type = DbColumnType.text,
    this.nullable = true,
  });

  /// The column name.
  final String name;

  /// The data type stored in this column.
  final DbColumnType type;

  /// Whether the column accepts null values.
  final bool nullable;
}

/// Transforms all stored records when the schema version increases by one step.
///
/// Receives every raw record from the previous version and must return the
/// equivalent records in the new schema. Add, remove, or rename fields as
/// needed.
///
/// ### Example — rename field `title` → `name` in v2
/// ```dart
/// List<Map<String, dynamic>> _v1ToV2(List<Map<String, dynamic>> records) =>
///     records
///         .map((r) => {...r, 'name': r['title']}..remove('title'))
///         .toList();
/// ```
typedef DbMigration =
    List<Map<String, dynamic>> Function(List<Map<String, dynamic>> records);

/// Describes the full schema of a database table used by [DbAdapter].
class DbTableSchema {
  const DbTableSchema({
    required this.dbName,
    required this.tableName,
    required this.version,
    required this.columns,
    this.primaryKeyColumns = const [],
    this.migrations = const {},
  });

  /// Name of the database (or file) that holds this table.
  final String dbName;

  /// Name of the table (or equivalent collection / box) inside the database.
  final String tableName;

  /// Schema version. Increment this to trigger a migration.
  final int version;

  /// All columns in the table, **including** any internally managed ones
  /// (e.g. the cache-timestamp column added by [DBCache]).
  final List<DbColumnDefinition> columns;

  /// The subset of column names that together form the primary / composite key.
  /// Used by [DbAdapter.upsert] to find and replace an existing record.
  /// When empty, every [upsert] call appends a new row.
  final List<String> primaryKeyColumns;

  /// Migration steps keyed by the version they migrate **to**.
  ///
  /// For example `{2: step}` runs `step` when upgrading from v1 → v2.
  /// Steps are applied in ascending version order, so upgrading from v1 to v3
  /// runs step 2 then step 3.
  ///
  /// Each step receives all records from the previous version and must return
  /// the transformed records for the new version.
  final Map<int, DbMigration> migrations;
}

/// Describes a single change event emitted by [DbAdapter.watch].
///
/// [T] is the type of the record involved in the event – typically
/// `Map<String, dynamic>` at the adapter level and the domain-model type `T`
/// at the [DBCache] level.
class DbCacheEvent<T> {
  const DbCacheEvent({required this.value, required this.deleted});

  /// The record involved in the event, or `null` when [deleted] is `true`.
  final T? value;

  /// Whether this event represents a deletion (or a full [DbAdapter.clear]).
  final bool deleted;
}

/// Abstract interface for the persistence layer used by [DBCache].
///
/// Implement this interface to swap the underlying database technology without
/// touching the cache or domain layers.
///
/// A concrete [DbAdapter] is responsible for:
///  - Opening / migrating the storage on [initialize].
///  - Translating the DB-agnostic CRUD calls into the native API of the chosen
///    database engine.
///
/// Example engines: Hive, SQLite, in-memory (for tests).
abstract class DbAdapter {
  /// Opens and, if necessary, creates or migrates the underlying storage
  /// according to [schema].
  ///
  /// Must be called once before any other method.
  Future<void> initialize(DbTableSchema schema);

  /// Inserts [values] as a new record, or replaces the existing record whose
  /// primary-key columns match those in [values] (when
  /// [DbTableSchema.primaryKeyColumns] is non-empty).
  Future<void> upsert(Map<String, dynamic> values);

  /// Returns every record currently in the table.
  Future<List<Map<String, dynamic>>> findAll();

  /// Returns all records where every entry in [conditions] matches
  /// (AND semantics, equality only).
  Future<List<Map<String, dynamic>>> findBy(Map<String, Object?> conditions);

  /// Returns the first record where every entry in [conditions] matches,
  /// or `null` if no such record exists.
  Future<Map<String, dynamic>?> findOneBy(Map<String, Object?> conditions);

  /// Deletes all records where every entry in [conditions] matches.
  Future<void> deleteBy(Map<String, Object?> conditions);

  /// Removes all records from the table.
  Future<void> clear();

  /// Returns a broadcast stream that emits a [DbCacheEvent] whenever a record
  /// is inserted, updated, or deleted.
  ///
  /// When [conditions] is non-empty only events whose record matches every
  /// entry (AND equality semantics) are emitted.
  /// Deletion events are always forwarded because the original record values
  /// are no longer available for filtering.
  Stream<DbCacheEvent<Map<String, dynamic>>> watch({
    Map<String, Object?> conditions = const {},
  });

  /// Releases any resources held by this adapter (open file handles, etc.).
  Future<void> close();
}
