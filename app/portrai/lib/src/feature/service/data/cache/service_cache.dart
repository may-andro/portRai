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
  int get tableVersion => 1;

  @override
  List<DbColumnDefinition> get columns => [
    const DbColumnDefinition(name: 'title', nullable: false),
    const DbColumnDefinition(name: 'description', nullable: false),
    const DbColumnDefinition(name: 'image', nullable: false),
    const DbColumnDefinition(name: 'detail', nullable: false),
    const DbColumnDefinition(name: 'locale', nullable: false),
  ];

  @override
  List<String> get primaryKeyColumns => ['title', 'locale'];

  @override
  ServiceModel deserialize(Map<String, dynamic> map) {
    return ServiceModel.fromJson(map);
  }

  @override
  Map<String, dynamic> serialize(ServiceModel model) => model.toJson();

  @override
  Duration get timeToLive => 7.days;
}
