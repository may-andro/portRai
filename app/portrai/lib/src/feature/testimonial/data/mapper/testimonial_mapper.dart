import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/testimonial/data/model/_model.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

@register
class TestimonialMapper
    implements BiMapper<TestimonialModel, TestimonialEntity> {
  const TestimonialMapper({required this.appLocale});

  final AppLocale appLocale;

  @override
  TestimonialModel from(TestimonialEntity entity) => TestimonialModel(
    id: entity.id,
    name: entity.name,
    position: entity.position,
    company: entity.company,
    testimonial: entity.testimonial,
    date: entity.date,
    profileImage: entity.profileImage,
    companyLogo: entity.companyLogo,
    linkedinProfile: entity.linkedinProfile,
    projectContext: entity.projectContext,
    locale: appLocale.languageCode,
  );

  @override
  TestimonialEntity to(TestimonialModel model) => TestimonialEntity(
    id: model.id,
    name: model.name,
    position: model.position,
    company: model.company,
    testimonial: model.testimonial,
    date: model.date,
    profileImage: model.profileImage,
    companyLogo: model.companyLogo,
    linkedinProfile: model.linkedinProfile,
    projectContext: model.projectContext,
  );
}
