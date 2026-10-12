import 'dart:convert';

import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/testimonial/data/model/_model.dart';

@registerSingleton
class TestimonialCache extends DBCache<TestimonialModel> {
  TestimonialCache();

  @override
  String get dbName => 'testimonial_db';

  @override
  String get tableName => 'testimonial_table';

  @override
  int get tableVersion => 4;

  @override
  List<DbColumnDefinition> get columns => [
    const DbColumnDefinition(name: 'id', nullable: false),
    const DbColumnDefinition(name: 'name', nullable: false),
    const DbColumnDefinition(name: 'position', nullable: false),
    const DbColumnDefinition(name: 'company', nullable: false),
    const DbColumnDefinition(name: 'testimonial', nullable: false),
    const DbColumnDefinition(name: 'date', nullable: false),
    const DbColumnDefinition(name: 'profileImage'),
    const DbColumnDefinition(name: 'companyLogo', nullable: false),
    const DbColumnDefinition(name: 'linkedinProfile', nullable: false),
    const DbColumnDefinition(name: 'projectContext', nullable: false),
    const DbColumnDefinition(name: 'experienceId', nullable: false),
    const DbColumnDefinition(name: 'projectIds', nullable: false),
    const DbColumnDefinition(name: 'locale', nullable: false),
  ];

  @override
  List<String> get primaryKeyColumns => ['id', 'locale'];

  @override
  TestimonialModel deserialize(Map<String, dynamic> map) {
    final modifiedMap = Map<String, dynamic>.from(map);
    if (modifiedMap['projectIds'] is String) {
      modifiedMap['projectIds'] = jsonDecode(
        modifiedMap['projectIds'] as String,
      );
    }
    return TestimonialModel.fromJson(modifiedMap);
  }

  @override
  Map<String, dynamic> serialize(TestimonialModel model) {
    final json = model.toJson();
    json['projectIds'] = jsonEncode(json['projectIds']);
    return json;
  }

  @override
  Duration get timeToLive => 1.minutes;
}
