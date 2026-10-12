import 'dart:convert';

import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/service/data/model/_model.dart';

@registerSingleton
class ServiceCache extends DBCache<ServiceModel> {
  ServiceCache();

  @override
  String get dbName => 'service_db';

  @override
  String get tableName => 'service_table';

  @override
  int get tableVersion => 2;

  @override
  List<DbColumnDefinition> get columns => [
    const DbColumnDefinition(name: 'title', nullable: false),
    const DbColumnDefinition(name: 'description', nullable: false),
    const DbColumnDefinition(name: 'image', nullable: false),
    const DbColumnDefinition(name: 'detail', nullable: false),
    const DbColumnDefinition(name: 'locale', nullable: false),
    const DbColumnDefinition(name: 'id'),
    const DbColumnDefinition(name: 'deliverables', nullable: false),
    const DbColumnDefinition(name: 'technologies', nullable: false),
    const DbColumnDefinition(name: 'projectIds', nullable: false),
    const DbColumnDefinition(name: 'engagementTypes', nullable: false),
    const DbColumnDefinition(name: 'idealFor', nullable: false),
    const DbColumnDefinition(name: 'process', nullable: false),
    const DbColumnDefinition(name: 'faq', nullable: false),
  ];

  @override
  List<String> get primaryKeyColumns => ['title', 'locale'];

  @override
  ServiceModel deserialize(Map<String, dynamic> map) {
    final modifiedMap = Map<String, dynamic>.from(map);
    for (final key in _listColumns) {
      if (modifiedMap[key] is String) {
        modifiedMap[key] = jsonDecode(modifiedMap[key] as String);
      }
    }
    return ServiceModel.fromJson(modifiedMap);
  }

  @override
  Map<String, dynamic> serialize(ServiceModel model) {
    final json = model.toJson();
    for (final key in _listColumns) {
      json[key] = jsonEncode(json[key]);
    }
    return json;
  }

  static const _listColumns = [
    'deliverables',
    'technologies',
    'projectIds',
    'engagementTypes',
    'idealFor',
    'process',
    'faq',
  ];

  @override
  Duration get timeToLive => 7.days;
}
