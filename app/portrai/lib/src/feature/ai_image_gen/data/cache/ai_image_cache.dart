import 'dart:typed_data';

import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_image_gen/data/model/_model.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/use_case/_use_case.dart';

@registerSingleton
class AiImageCache extends DBCache<AiImageModel> {
  AiImageCache();

  @override
  String get dbName => 'ai_image_db';

  @override
  String get tableName => 'ai_image_table';

  @override
  int get tableVersion => 1;

  @override
  List<DbColumnDefinition> get columns => [
    const DbColumnDefinition(name: 'key', nullable: false),
    const DbColumnDefinition(name: 'mimeType', nullable: false),
    const DbColumnDefinition(
      name: 'bytes',
      type: DbColumnType.blob,
      nullable: false,
    ),
  ];

  @override
  List<String> get primaryKeyColumns => ['key'];

  @override
  AiImageModel deserialize(Map<String, dynamic> map) => AiImageModel(
    key: map['key'] as String,
    mimeType: map['mimeType'] as String,
    bytes: map['bytes'] as Uint8List,
  );

  @override
  Map<String, dynamic> serialize(AiImageModel model) => {
    'key': model.key,
    'mimeType': model.mimeType,
    'bytes': model.bytes,
  };

  @override
  Duration get timeToLive => AiImageRequestLimits.cacheDays.days;
}
