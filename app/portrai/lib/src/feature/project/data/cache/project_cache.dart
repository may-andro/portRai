import 'dart:convert';

import 'package:cache/cache.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/project/data/model/_model.dart';

@registerSingleton
class ProjectCache extends DBCache<ProjectModel> {
  ProjectCache();

  @override
  String get dbName => 'project_db';

  @override
  String get tableName => 'project_table';

  @override
  int get tableVersion => 1;

  @override
  List<DbColumnDefinition> get columns => [
    const DbColumnDefinition(name: 'title', nullable: false),
    const DbColumnDefinition(name: 'description', nullable: false),
    const DbColumnDefinition(name: 'longDescription', nullable: false),
    const DbColumnDefinition(name: 'technologies', nullable: false),
    const DbColumnDefinition(name: 'category', nullable: false),
    const DbColumnDefinition(name: 'status', nullable: false),
    const DbColumnDefinition(name: 'startDate', nullable: false),
    const DbColumnDefinition(name: 'endDate'),
    const DbColumnDefinition(name: 'image', nullable: false),
    const DbColumnDefinition(name: 'appStore'),
    const DbColumnDefinition(name: 'playStore'),
    const DbColumnDefinition(name: 'website'),
    const DbColumnDefinition(name: 'github'),
    const DbColumnDefinition(name: 'features', nullable: false),
    const DbColumnDefinition(name: 'achievements', nullable: false),
    const DbColumnDefinition(
      name: 'teamSize',
      type: DbColumnType.integer,
      nullable: false,
    ),
    const DbColumnDefinition(name: 'role', nullable: false),
    const DbColumnDefinition(name: 'id', nullable: false),
    const DbColumnDefinition(name: 'locale', nullable: false),
  ];

  @override
  List<String> get primaryKeyColumns => ['title', 'locale'];

  @override
  ProjectModel deserialize(Map<String, dynamic> map) {
    final modifiedMap = Map<String, dynamic>.from(map);

    // Convert JSON strings back to Lists
    if (modifiedMap.containsKey('technologies') &&
        modifiedMap['technologies'] is String) {
      modifiedMap['technologies'] = jsonDecode(
        modifiedMap['technologies'] as String,
      );
    }

    if (modifiedMap.containsKey('features') &&
        modifiedMap['features'] is String) {
      modifiedMap['features'] = jsonDecode(modifiedMap['features'] as String);
    }

    if (modifiedMap.containsKey('achievements') &&
        modifiedMap['achievements'] is String) {
      modifiedMap['achievements'] = jsonDecode(
        modifiedMap['achievements'] as String,
      );
    }

    return ProjectModel.fromJson(modifiedMap);
  }

  @override
  Map<String, dynamic> serialize(ProjectModel model) {
    final json = model.toJson();

    // Convert Lists to JSON strings for storage
    if (json.containsKey('technologies') && json['technologies'] is List) {
      json['technologies'] = jsonEncode(json['technologies']);
    }

    if (json.containsKey('features') && json['features'] is List) {
      json['features'] = jsonEncode(json['features']);
    }

    if (json.containsKey('achievements') && json['achievements'] is List) {
      json['achievements'] = jsonEncode(json['achievements']);
    }

    return json;
  }
}
