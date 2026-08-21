import 'dart:convert';

import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/data/model/_model.dart';

@registerSingleton
class ProfileCache extends DBCache<ProfileModel> {
  ProfileCache();

  @override
  String get dbName => 'profile_db';

  @override
  String get tableName => 'profile_table';

  @override
  int get tableVersion => 1;

  @override
  List<DbColumnDefinition> get columns => [
    const DbColumnDefinition(name: 'fullName', nullable: false),
    const DbColumnDefinition(name: 'title', nullable: false),
    const DbColumnDefinition(name: 'subtitle', nullable: false),
    const DbColumnDefinition(name: 'email', nullable: false),
    const DbColumnDefinition(name: 'phone', nullable: false),
    const DbColumnDefinition(name: 'profileImage', nullable: false),
    const DbColumnDefinition(name: 'coverImage', nullable: false),
    const DbColumnDefinition(name: 'summary', nullable: false),
    const DbColumnDefinition(name: 'detailedBio', nullable: false),
    const DbColumnDefinition(name: 'elevatorPitch', nullable: false),
    const DbColumnDefinition(name: 'uniqueValueProposition', nullable: false),
    const DbColumnDefinition(name: 'publishedAt', nullable: false),
    const DbColumnDefinition(name: 'resume', nullable: false),
    const DbColumnDefinition(name: 'socialLinks', nullable: false),
    const DbColumnDefinition(name: 'availability', nullable: false),
    const DbColumnDefinition(name: 'workingHours', nullable: false),
    const DbColumnDefinition(name: 'currentRole', nullable: false),
    const DbColumnDefinition(name: 'currentCompany', nullable: false),
    const DbColumnDefinition(
      name: 'yearsOfExperience',
      type: DbColumnType.integer,
      nullable: false,
    ),
    const DbColumnDefinition(
      name: 'projectsDelivered',
      type: DbColumnType.integer,
      nullable: false,
    ),
    const DbColumnDefinition(name: 'location', nullable: false),
    const DbColumnDefinition(name: 'languages', nullable: false),
    const DbColumnDefinition(name: 'educations', nullable: false),
    const DbColumnDefinition(name: 'locale', nullable: false),
  ];

  @override
  List<String> get primaryKeyColumns => ['email', 'locale'];

  @override
  ProfileModel deserialize(Map<String, dynamic> map) {
    final modifiedMap = Map<String, dynamic>.from(map);

    // Convert JSON strings back to complex objects/lists
    if (modifiedMap.containsKey('publishedAt') &&
        modifiedMap['publishedAt'] is String) {
      modifiedMap['publishedAt'] = jsonDecode(
        modifiedMap['publishedAt'] as String,
      );
    }

    if (modifiedMap.containsKey('resume') && modifiedMap['resume'] is String) {
      modifiedMap['resume'] = jsonDecode(modifiedMap['resume'] as String);
    }

    if (modifiedMap.containsKey('socialLinks') &&
        modifiedMap['socialLinks'] is String) {
      modifiedMap['socialLinks'] = jsonDecode(
        modifiedMap['socialLinks'] as String,
      );
    }

    if (modifiedMap.containsKey('availability') &&
        modifiedMap['availability'] is String) {
      modifiedMap['availability'] = jsonDecode(
        modifiedMap['availability'] as String,
      );
    }

    if (modifiedMap.containsKey('workingHours') &&
        modifiedMap['workingHours'] is String) {
      modifiedMap['workingHours'] = jsonDecode(
        modifiedMap['workingHours'] as String,
      );
    }

    if (modifiedMap.containsKey('location') &&
        modifiedMap['location'] is String) {
      modifiedMap['location'] = jsonDecode(modifiedMap['location'] as String);
    }

    if (modifiedMap.containsKey('languages') &&
        modifiedMap['languages'] is String) {
      modifiedMap['languages'] = jsonDecode(modifiedMap['languages'] as String);
    }

    if (modifiedMap.containsKey('educations') &&
        modifiedMap['educations'] is String) {
      modifiedMap['educations'] = jsonDecode(
        modifiedMap['educations'] as String,
      );
    }

    return ProfileModel.fromJson(modifiedMap);
  }

  @override
  Map<String, dynamic> serialize(ProfileModel model) {
    final json = model.toJson();

    // Convert complex objects and lists to JSON strings for SQLite storage
    if (json.containsKey('publishedAt') && json['publishedAt'] is List) {
      json['publishedAt'] = jsonEncode(json['publishedAt']);
    }

    if (json.containsKey('resume') && json['resume'] is Map) {
      json['resume'] = jsonEncode(json['resume']);
    }

    if (json.containsKey('socialLinks') && json['socialLinks'] is List) {
      json['socialLinks'] = jsonEncode(json['socialLinks']);
    }

    if (json.containsKey('availability') && json['availability'] is Map) {
      json['availability'] = jsonEncode(json['availability']);
    }

    if (json.containsKey('workingHours') && json['workingHours'] is Map) {
      json['workingHours'] = jsonEncode(json['workingHours']);
    }

    if (json.containsKey('location') && json['location'] is Map) {
      json['location'] = jsonEncode(json['location']);
    }

    if (json.containsKey('languages') && json['languages'] is List) {
      json['languages'] = jsonEncode(json['languages']);
    }

    if (json.containsKey('educations') && json['educations'] is List) {
      json['educations'] = jsonEncode(json['educations']);
    }

    return json;
  }

  @override
  Duration get timeToLive => 7.days;
}
