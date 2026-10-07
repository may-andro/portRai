import 'package:portrai/src/feature/testimonial/data/model/_model.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

TestimonialEntity createTestimonialEntity({
  String id = 'john-doe',
  String name = 'John Doe',
  String position = 'Engineering Manager',
  String company = 'Acme',
  String testimonial = 'Rai consistently delivers thoughtful Flutter work.',
  String date = '2025',
  String profileImage = 'https://example.com/john.png',
  String companyLogo = 'https://example.com/acme.png',
  String linkedinProfile = 'https://linkedin.com/in/john-doe',
  String projectContext = 'Portfolio App',
}) {
  return TestimonialEntity(
    id: id,
    name: name,
    position: position,
    company: company,
    testimonial: testimonial,
    date: date,
    profileImage: profileImage,
    companyLogo: companyLogo,
    linkedinProfile: linkedinProfile,
    projectContext: projectContext,
  );
}

TestimonialModel createTestimonialModel({
  String locale = 'en',
  String id = 'john-doe',
  String name = 'John Doe',
  String position = 'Engineering Manager',
  String company = 'Acme',
  String testimonial = 'Rai consistently delivers thoughtful Flutter work.',
  String date = '2025',
  String profileImage = 'https://example.com/john.png',
  String companyLogo = 'https://example.com/acme.png',
  String linkedinProfile = 'https://linkedin.com/in/john-doe',
  String projectContext = 'Portfolio App',
}) {
  return TestimonialModel(
    id: id,
    name: name,
    position: position,
    company: company,
    testimonial: testimonial,
    date: date,
    profileImage: profileImage,
    companyLogo: companyLogo,
    linkedinProfile: linkedinProfile,
    projectContext: projectContext,
    locale: locale,
  );
}

Map<String, dynamic> createTestimonialJson({
  String locale = 'en',
  String id = 'john-doe',
  String name = 'John Doe',
  String position = 'Engineering Manager',
  String company = 'Acme',
  String testimonial = 'Rai consistently delivers thoughtful Flutter work.',
  String date = '2025',
  String profileImage = 'https://example.com/john.png',
  String companyLogo = 'https://example.com/acme.png',
  String linkedinProfile = 'https://linkedin.com/in/john-doe',
  String projectContext = 'Portfolio App',
}) {
  return createTestimonialModel(
    locale: locale,
    id: id,
    name: name,
    position: position,
    company: company,
    testimonial: testimonial,
    date: date,
    profileImage: profileImage,
    companyLogo: companyLogo,
    linkedinProfile: linkedinProfile,
    projectContext: projectContext,
  ).toJson();
}

List<Map<String, dynamic>> createTestimonialListJson({String locale = 'en'}) {
  return [
    createTestimonialJson(locale: locale),
    createTestimonialJson(
      locale: locale,
      id: 'jane-doe',
      name: 'Jane Doe',
      position: 'Product Manager',
      company: 'Globex',
      testimonial: 'Rai is a reliable partner for complex product work.',
      date: '2024',
      profileImage: 'https://example.com/jane.png',
      companyLogo: 'https://example.com/globex.png',
      linkedinProfile: 'https://linkedin.com/in/jane-doe',
      projectContext: 'Admin Console',
    ),
  ];
}

Map<String, dynamic> createTestimonialAssetJson({
  String locale = 'en',
  List<Map<String, dynamic>>? testimonials,
}) {
  return {
    locale: {
      'testimonials': testimonials ?? [createTestimonialJson(locale: locale)],
    },
  };
}
