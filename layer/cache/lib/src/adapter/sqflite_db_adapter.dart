import 'dart:async';

import 'package:cache/src/adapter/db_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// A [DbAdapter] backed by SQLite via the `sqflite` package.
///
/// Supports Android, iOS, macOS, and web (through `sqflite_common_ffi_web`).
class SqfliteDbAdapter implements DbAdapter {
  SqfliteDbAdapter();

  Database? _db;
  late DbTableSchema _schema;

  static bool _isWebFactoryInitialized = false;

  final _watchController =
      StreamController<DbCacheEvent<Map<String, dynamic>>>.broadcast();

  // ── DbAdapter ──────────────────────────────────────────────────────────────

  @override
  Future<void> initialize(DbTableSchema schema) async {
    _schema = schema;

    String path;
    if (kIsWeb) {
      if (!_isWebFactoryInitialized) {
        databaseFactory = databaseFactoryFfiWeb;
        _isWebFactoryInitialized = true;
      }
      path = 'portrai_web_${schema.dbName}.db';
    } else {
      final databasePath = await getDatabasesPath();
      path = '$databasePath/${schema.dbName}.db';
    }

    _db = await openDatabase(
      path,
      version: schema.version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  @override
  Future<void> upsert(Map<String, dynamic> values) async {
    final db = _requireDb();
    await db.transaction((txn) async {
      await txn.insert(
        _schema.tableName,
        values,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    _watchController.add(DbCacheEvent(value: values, deleted: false));
  }

  @override
  Future<List<Map<String, dynamic>>> findAll() {
    final db = _requireDb();
    return db.transaction<List<Map<String, dynamic>>>((txn) {
      return txn.query(_schema.tableName);
    });
  }

  @override
  Future<List<Map<String, dynamic>>> findBy(Map<String, Object?> conditions) {
    final db = _requireDb();
    final where = _buildWhere(conditions);
    final args = _buildWhereArgs(conditions);
    return db.transaction<List<Map<String, dynamic>>>((txn) {
      return txn.query(_schema.tableName, where: where, whereArgs: args);
    });
  }

  @override
  Future<Map<String, dynamic>?> findOneBy(Map<String, Object?> conditions) {
    final db = _requireDb();
    final where = _buildWhere(conditions);
    final args = _buildWhereArgs(conditions);
    return db.transaction<Map<String, dynamic>?>((txn) async {
      final results = await txn.query(
        _schema.tableName,
        where: where,
        whereArgs: args,
        limit: 1,
      );
      return results.isNotEmpty ? results.first : null;
    });
  }

  @override
  Future<void> deleteBy(Map<String, Object?> conditions) async {
    final db = _requireDb();
    final where = _buildWhere(conditions);
    final args = _buildWhereArgs(conditions);
    await db.transaction((txn) async {
      await txn.delete(_schema.tableName, where: where, whereArgs: args);
    });
    _watchController.add(const DbCacheEvent(value: null, deleted: true));
  }

  @override
  Future<void> clear() async {
    final db = _requireDb();
    await db.transaction((txn) async {
      await txn.delete(_schema.tableName);
    });
    _watchController.add(const DbCacheEvent(value: null, deleted: true));
  }

  @override
  Stream<DbCacheEvent<Map<String, dynamic>>> watch({
    Map<String, Object?> conditions = const {},
  }) {
    if (conditions.isEmpty) return _watchController.stream;

    return _watchController.stream.where((event) {
      if (event.deleted) return true;
      final record = event.value;
      if (record == null) return false;
      return conditions.entries.every((e) => record[e.key] == e.value);
    });
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
    await _watchController.close();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Database _requireDb() {
    final db = _db;
    if (db == null) {
      throw StateError(
        'SqfliteDbAdapter has not been initialized. '
        'Call initialize() first.',
      );
    }
    return db;
  }

  String _buildWhere(Map<String, Object?> conditions) {
    return conditions.keys.map((k) => '$k = ?').join(' AND ');
  }

  List<Object?> _buildWhereArgs(Map<String, Object?> conditions) {
    return conditions.values.toList();
  }

  Future<void> _onCreate(Database db, int version) async {
    final columnDefs = <String>[];
    for (final col in _schema.columns) {
      final sqlType = _sqlType(col.type);
      final nullable = col.nullable ? '' : ' NOT NULL';
      columnDefs.add('${col.name} $sqlType$nullable');
    }

    final allParts = ['_id INTEGER', ...columnDefs];

    if (_schema.primaryKeyColumns.isNotEmpty) {
      allParts.add('PRIMARY KEY (${_schema.primaryKeyColumns.join(', ')})');
    }

    final sql = 'CREATE TABLE ${_schema.tableName} (${allParts.join(', ')})';

    if (kDebugMode) {
      print('Creating table with SQL: $sql');
    }

    await db.execute(sql);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (_schema.migrations.isEmpty) {
      // No migration steps defined — drop and recreate (old behaviour).
      await db.execute('DROP TABLE IF EXISTS ${_schema.tableName}');
      await _onCreate(db, newVersion);
      return;
    }

    // Run migration steps in ascending version order.
    var records = await db.query(_schema.tableName);

    final sortedVersions = _schema.migrations.keys.toList()..sort();
    for (final version in sortedVersions) {
      if (version > oldVersion && version <= newVersion) {
        final migration = _schema.migrations[version]!;
        records = migration(
          List<Map<String, dynamic>>.from(
            records.map((r) => Map<String, dynamic>.from(r)),
          ),
        );
      }
    }

    // Recreate table with new schema.
    await db.execute('DROP TABLE IF EXISTS ${_schema.tableName}');
    await _onCreate(db, newVersion);

    // Re-insert migrated records.
    for (final record in records) {
      await db.insert(
        _schema.tableName,
        record,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  String _sqlType(DbColumnType type) {
    switch (type) {
      case DbColumnType.integer:
        return 'INTEGER';
      case DbColumnType.real:
        return 'REAL';
      case DbColumnType.text:
        return 'TEXT';
      case DbColumnType.blob:
        return 'BLOB';
    }
  }
}
