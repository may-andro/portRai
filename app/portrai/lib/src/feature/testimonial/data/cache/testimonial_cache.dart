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
  int get tableVersion => 1;

  @override
  List<DbColumnDefinition> get columns => [
    const DbColumnDefinition(name: 'id', nullable: false),
    const DbColumnDefinition(name: 'name', nullable: false),
    const DbColumnDefinition(name: 'position', nullable: false),
    const DbColumnDefinition(name: 'company', nullable: false),
    const DbColumnDefinition(name: 'testimonial', nullable: false),
    const DbColumnDefinition(name: 'date', nullable: false),
    const DbColumnDefinition(name: 'profileImage', nullable: false),
    const DbColumnDefinition(name: 'companyLogo', nullable: false),
    const DbColumnDefinition(name: 'linkedinProfile', nullable: false),
    const DbColumnDefinition(name: 'projectContext', nullable: false),
    const DbColumnDefinition(name: 'locale', nullable: false),
  ];

  @override
  List<String> get primaryKeyColumns => ['id', 'locale'];

  @override
  TestimonialModel deserialize(Map<String, dynamic> map) {
    return TestimonialModel.fromJson(map);
  }

  @override
  Map<String, dynamic> serialize(TestimonialModel model) {
    return model.toJson();
  }

  @override
  Duration get timeToLive => 1.minutes;
}
