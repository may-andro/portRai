import 'dart:convert';

import 'package:cache/cache.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/expertise/data/model/_model.dart';

@registerSingleton
class ExpertiseCache extends DBCache<ExpertiseModel> {
  ExpertiseCache();

  @override
  String get dbName => 'expertise_db';

  @override
  String get tableName => 'expertise_table';

  @override
  int get tableVersion => 1;

  @override
  List<DbColumnDefinition> get columns => [
    const DbColumnDefinition(name: 'image', nullable: false),
    const DbColumnDefinition(name: 'title', nullable: false),
    const DbColumnDefinition(name: 'skills', nullable: false),
    const DbColumnDefinition(name: 'locale', nullable: false),
  ];

  @override
  List<String> get primaryKeyColumns => ['title', 'locale'];

  @override
  ExpertiseModel deserialize(Map<String, dynamic> map) {
    final modifiedMap = Map<String, dynamic>.from(map);

    // Convert JSON string back to List
    if (modifiedMap.containsKey('skills') && modifiedMap['skills'] is String) {
      modifiedMap['skills'] = jsonDecode(modifiedMap['skills'] as String);
    }

    return ExpertiseModel.fromJson(modifiedMap);
  }

  @override
  Map<String, dynamic> serialize(ExpertiseModel model) {
    final json = model.toJson();

    // Convert List to JSON string for storage
    if (json.containsKey('skills') && json['skills'] is List) {
      json['skills'] = jsonEncode(json['skills']);
    }

    return json;
  }
}
