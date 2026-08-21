import 'dart:convert';

import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/data/model/_model.dart';

@registerSingleton
class ExperienceCache extends DBCache<ExperienceModel> {
  ExperienceCache();

  @override
  String get dbName => 'experience_db';

  @override
  String get tableName => 'experience_table';

  @override
  int get tableVersion => 1;

  @override
  List<DbColumnDefinition> get columns => [
    const DbColumnDefinition(name: 'company', nullable: false),
    const DbColumnDefinition(name: 'position', nullable: false),
    const DbColumnDefinition(name: 'location', nullable: false),
    const DbColumnDefinition(name: 'startDate', nullable: false),
    const DbColumnDefinition(name: 'endDate'),
    const DbColumnDefinition(
      name: 'current',
      type: DbColumnType.integer,
      nullable: false,
    ),
    const DbColumnDefinition(name: 'employmentType', nullable: false),
    const DbColumnDefinition(name: 'description', nullable: false),
    const DbColumnDefinition(name: 'longDescription', nullable: false),
    const DbColumnDefinition(name: 'responsibilities', nullable: false),
    const DbColumnDefinition(name: 'achievements', nullable: false),
    const DbColumnDefinition(name: 'technologies', nullable: false),
    const DbColumnDefinition(name: 'companyLogo', nullable: false),
    const DbColumnDefinition(name: 'url'),
    const DbColumnDefinition(name: 'id', nullable: false),
    const DbColumnDefinition(name: 'locale', nullable: false),
  ];

  @override
  List<String> get primaryKeyColumns => ['id', 'locale'];

  @override
  ExperienceModel deserialize(Map<String, dynamic> map) {
    // Convert INTEGER back to bool for 'current' field
    final modifiedMap = Map<String, dynamic>.from(map);

    if (modifiedMap.containsKey('current')) {
      modifiedMap['current'] = modifiedMap['current'] == 1;
    }

    // Convert JSON strings back to Lists
    if (modifiedMap.containsKey('responsibilities') &&
        modifiedMap['responsibilities'] is String) {
      modifiedMap['responsibilities'] = jsonDecode(
        modifiedMap['responsibilities'] as String,
      );
    }

    if (modifiedMap.containsKey('achievements') &&
        modifiedMap['achievements'] is String) {
      modifiedMap['achievements'] = jsonDecode(
        modifiedMap['achievements'] as String,
      );
    }

    if (modifiedMap.containsKey('technologies') &&
        modifiedMap['technologies'] is String) {
      modifiedMap['technologies'] = jsonDecode(
        modifiedMap['technologies'] as String,
      );
    }

    return ExperienceModel.fromJson(modifiedMap);
  }

  @override
  Map<String, dynamic> serialize(ExperienceModel model) {
    final json = model.toJson();

    // Convert bool to INTEGER (0 or 1) for SQLite
    if (json.containsKey('current')) {
      json['current'] = json['current'] == true ? 1 : 0;
    }

    // Convert Lists to JSON strings for SQLite storage
    if (json.containsKey('responsibilities') &&
        json['responsibilities'] is List) {
      json['responsibilities'] = jsonEncode(json['responsibilities']);
    }

    if (json.containsKey('achievements') && json['achievements'] is List) {
      json['achievements'] = jsonEncode(json['achievements']);
    }

    if (json.containsKey('technologies') && json['technologies'] is List) {
      json['technologies'] = jsonEncode(json['technologies']);
    }

    return json;
  }

  @override
  Duration get timeToLive => 7.days;
}
