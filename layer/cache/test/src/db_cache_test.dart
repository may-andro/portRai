import 'package:cache/cache.dart';
import 'package:cache/src/adapter/sqflite_db_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Model for testing single primary key
class SimpleTestModel {
  SimpleTestModel({required this.id, required this.name});

  factory SimpleTestModel.fromJson(Map<String, dynamic> json) {
    return SimpleTestModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  final String id;
  final String name;

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class SimpleTestModelCache extends DBCache<SimpleTestModel> {
  SimpleTestModelCache({this.version = 1, this.ttl = Duration.zero})
      : super(adapter: SqfliteDbAdapter());

  final int version;
  final Duration ttl;

  @override
  String get dbName => 'simple_test_db';

  @override
  String get tableName => 'simple_test_table';

  @override
  int get tableVersion => version;

  @override
  List<DbColumnDefinition> get columns => [
    const DbColumnDefinition(name: 'id', nullable: false),
    const DbColumnDefinition(name: 'name', nullable: false),
  ];

  @override
  List<String> get primaryKeyColumns => ['id'];

  @override
  SimpleTestModel deserialize(Map<String, dynamic> map) =>
      SimpleTestModel.fromJson(map);

  @override
  Map<String, dynamic> serialize(SimpleTestModel model) => model.toJson();

  @override
  Duration get timeToLive => ttl;
}

// Model for testing composite primary key
class TestModel {
  TestModel({required this.id, required this.name, required this.category});

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
    );
  }

  final String id;
  final String name;
  final String category;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
  };
}

class TestModelCache extends DBCache<TestModel> {
  TestModelCache({this.version = 1, this.ttl = Duration.zero})
      : super(adapter: SqfliteDbAdapter());

  final int version;
  final Duration ttl;

  @override
  String get dbName => 'test_db';

  @override
  String get tableName => 'test_table';

  @override
  int get tableVersion => version;

  @override
  List<DbColumnDefinition> get columns => [
    const DbColumnDefinition(name: 'id', nullable: false),
    const DbColumnDefinition(name: 'name', nullable: false),
    const DbColumnDefinition(name: 'category', nullable: false),
  ];

  @override
  List<String> get primaryKeyColumns => ['id', 'category'];

  @override
  TestModel deserialize(Map<String, dynamic> map) => TestModel.fromJson(map);

  @override
  Map<String, dynamic> serialize(TestModel model) => model.toJson();

  @override
  Duration get timeToLive => ttl;
}

void main() {
  group('DBCache', () {
    group('composite primary key', () {
      late TestModelCache testModelCache;

      setUpAll(() {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      });

      setUp(() async {
        await databaseFactory.deleteDatabase('test_db.db');
        testModelCache = TestModelCache();
      });

      tearDownAll(() async {
        await databaseFactory.deleteDatabase('test_db.db');
      });

      test('should insert and retrieve data', () async {
        final testModel = TestModel(id: '1', name: 'Test', category: 'A');
        await testModelCache.put(testModel);

        final result = await testModelCache.getAll();

        expect(result.length, 1);
        expect(result.first.name, 'Test');
        expect(result.first.id, '1');
        expect(result.first.category, 'A');
      });

      test('should delete data by conditions', () async {
        final testModel = TestModel(id: '1', name: 'Test', category: 'A');
        await testModelCache.put(testModel);

        await testModelCache.delete({'name': 'Test'});

        final results = await testModelCache.getAll();

        await pumpEventQueue();

        expect(results.isEmpty, isTrue);
      });

      test('should deletes expired items', () async {
        final expiredCache = TestModelCache(
          ttl: const Duration(milliseconds: 1),
        );
        final testModel = TestModel(id: '1', name: 'Test', category: 'A');
        await expiredCache.put(testModel);

        // Wait for items to expire
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final results = await expiredCache.getAll();

        // Drain fire-and-forget background deletions so they complete
        // before the test finishes and the database is closed.
        await pumpEventQueue();

        expect(results.length, 0);
      });

      test('should return empty database when nothing is present', () async {
        final items = await testModelCache.getAll();
        expect(items.length, 0);
      });

      test(
        'should support composite primary key with same id but different categories',
        () async {
          // Insert two models with same ID but different categories
          final testModel1 = TestModel(id: '1', name: 'Test A', category: 'A');
          final testModel2 = TestModel(id: '1', name: 'Test B', category: 'B');

          await testModelCache.put(testModel1);
          await testModelCache.put(testModel2);

          final results = await testModelCache.getAll();

          expect(results.length, 2);
          expect(
            results.any((m) => m.category == 'A' && m.name == 'Test A'),
            isTrue,
          );
          expect(
            results.any((m) => m.category == 'B' && m.name == 'Test B'),
            isTrue,
          );
        },
      );

      test('should update existing record with same composite key', () async {
        // Insert a model
        final testModel1 = TestModel(id: '1', name: 'Test 1', category: 'A');
        await testModelCache.put(testModel1);

        // Update with same id and category
        final testModel2 = TestModel(
          id: '1',
          name: 'Test Updated',
          category: 'A',
        );
        await testModelCache.put(testModel2);

        final results = await testModelCache.getAll();

        expect(results.length, 1);
        expect(results.first.name, 'Test Updated');
      });

      test('should query data by category', () async {
        final testModel1 = TestModel(id: '1', name: 'Test A1', category: 'A');
        final testModel2 = TestModel(id: '2', name: 'Test A2', category: 'A');
        final testModel3 = TestModel(id: '1', name: 'Test B', category: 'B');

        await testModelCache.put(testModel1);
        await testModelCache.put(testModel2);
        await testModelCache.put(testModel3);

        final categoryAResults = await testModelCache.query(
          conditions: {'category': 'A'},
        );

        expect(categoryAResults.length, 2);
        expect(categoryAResults.every((m) => m.category == 'A'), isTrue);
      });

      test('should query single item by composite key', () async {
        final testModel1 = TestModel(id: '1', name: 'Test A', category: 'A');
        final testModel2 = TestModel(id: '1', name: 'Test B', category: 'B');

        await testModelCache.put(testModel1);
        await testModelCache.put(testModel2);

        final result = await testModelCache.get(
          conditions: {'id': '1', 'category': 'A'},
        );

        expect(result, isNotNull);
        expect(result!.name, 'Test A');
        expect(result.category, 'A');
      });

      test('should delete data by composite key', () async {
        final testModel1 = TestModel(id: '1', name: 'Test A', category: 'A');
        final testModel2 = TestModel(id: '1', name: 'Test B', category: 'B');

        await testModelCache.put(testModel1);
        await testModelCache.put(testModel2);

        // Delete only category A
        await testModelCache.delete({'id': '1', 'category': 'A'});

        final results = await testModelCache.getAll();

        expect(results.length, 1);
        expect(results.first.category, 'B');
      });
    });

    group('single primary key', () {
      late SimpleTestModelCache simpleCache;

      setUpAll(() {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      });

      setUp(() async {
        await databaseFactory.deleteDatabase('simple_test_db.db');
        simpleCache = SimpleTestModelCache();
      });

      tearDownAll(() async {
        await databaseFactory.deleteDatabase('simple_test_db.db');
      });

      test('should insert and retrieve data with single primary key', () async {
        final model = SimpleTestModel(id: '1', name: 'Test');
        await simpleCache.put(model);

        final results = await simpleCache.getAll();

        expect(results.length, 1);
        expect(results.first.id, '1');
        expect(results.first.name, 'Test');
      });

      test('should prevent duplicate primary keys', () async {
        final model1 = SimpleTestModel(id: '1', name: 'Test 1');
        await simpleCache.put(model1);

        // Insert with same ID should replace
        final model2 = SimpleTestModel(id: '1', name: 'Test Updated');
        await simpleCache.put(model2);

        final results = await simpleCache.getAll();

        expect(results.length, 1);
        expect(results.first.name, 'Test Updated');
      });

      test('should allow different IDs', () async {
        final model1 = SimpleTestModel(id: '1', name: 'Test 1');
        final model2 = SimpleTestModel(id: '2', name: 'Test 2');

        await simpleCache.put(model1);
        await simpleCache.put(model2);

        final results = await simpleCache.getAll();

        expect(results.length, 2);
        expect(results.any((m) => m.id == '1' && m.name == 'Test 1'), isTrue);
        expect(results.any((m) => m.id == '2' && m.name == 'Test 2'), isTrue);
      });

      test('should query by id', () async {
        final model1 = SimpleTestModel(id: '1', name: 'Test 1');
        final model2 = SimpleTestModel(id: '2', name: 'Test 2');

        await simpleCache.put(model1);
        await simpleCache.put(model2);

        final result = await simpleCache.get(conditions: {'id': '1'});

        expect(result, isNotNull);
        expect(result!.id, '1');
        expect(result.name, 'Test 1');
      });

      test('should delete by id', () async {
        final model1 = SimpleTestModel(id: '1', name: 'Test 1');
        final model2 = SimpleTestModel(id: '2', name: 'Test 2');

        await simpleCache.put(model1);
        await simpleCache.put(model2);

        await simpleCache.delete({'id': '1'});

        final results = await simpleCache.getAll();

        expect(results.length, 1);
        expect(results.first.id, '2');
      });

      test('should delete all', () async {
        final model1 = SimpleTestModel(id: '1', name: 'Test 1');
        final model2 = SimpleTestModel(id: '2', name: 'Test 2');

        await simpleCache.put(model1);
        await simpleCache.put(model2);

        await simpleCache.deleteAll();

        final results = await simpleCache.getAll();

        expect(results.isEmpty, isTrue);
      });

      test('should handle expired items with single primary key', () async {
        final expiredCache = SimpleTestModelCache(
          ttl: const Duration(milliseconds: 1),
        );
        final model = SimpleTestModel(id: '1', name: 'Test');
        await expiredCache.put(model);

        // Wait for items to expire
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final results = await expiredCache.getAll();

        expect(results.length, 0);
      });
    });
  });
}
