import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/profile/data/mapper/_mapper.dart';

import '../../../../../mock/feature/profile/test_data/profile_test_data.dart';

void main() {
  final locale = AppLocale('nl');
  const availabilityMapper = AvailabilityMapper();
  const coordinatesMapper = CoordinatesMapper();
  const educationMapper = EducationMapper();
  const languageMapper = LanguageMapper();
  const locationMapper = LocationMapper(coordinatesMapper: CoordinatesMapper());
  const publishedAtMapper = PublishedAtMapper();
  const resumeMapper = ResumeMapper();
  const socialLinkMapper = SocialLinkMapper();
  const workingHoursMapper = WorkingHoursMapper();
  final profileMapper = ProfileMapper(
    publishedAtMapper: publishedAtMapper,
    resumeMapper: resumeMapper,
    socialLinkMapper: socialLinkMapper,
    availabilityMapper: availabilityMapper,
    workingHoursMapper: workingHoursMapper,
    locationMapper: locationMapper,
    languageMapper: languageMapper,
    educationMapper: educationMapper,
    appLocale: locale,
  );

  group('Profile mappers', () {
    test(
      'should map the full profile entity to a model with the configured locale',
      () {
        final result = profileMapper.from(createProfileEntity());

        expect(result.toJson(), createProfileModel(locale: 'nl').toJson());
      },
    );

    test('should map the full profile model to an entity', () {
      expect(
        profileMapper.to(createProfileModel(locale: 'nl')),
        createProfileEntity(),
      );
    });

    void expectBidirectional<M, E>(BiMapper<M, E> mapper, E entity, M model) {
      expect(
        (mapper.from(entity) as dynamic).toJson(),
        (model as dynamic).toJson(),
      );
      expect(mapper.to(model), entity);
    }

    final mapperCases = <String, void Function()>{
      'availability': () => expectBidirectional(
        availabilityMapper,
        createProfileEntity().availability,
        createProfileModel().availability,
      ),
      'coordinates': () => expectBidirectional(
        coordinatesMapper,
        createProfileEntity().location.coordinates,
        createProfileModel().location.coordinates,
      ),
      'education': () => expectBidirectional(
        educationMapper,
        createProfileEntity().educations.single,
        createProfileModel().educations.single,
      ),
      'language': () => expectBidirectional(
        languageMapper,
        createProfileEntity().languages.first,
        createProfileModel().languages.first,
      ),
      'location': () => expectBidirectional(
        locationMapper,
        createProfileEntity().location,
        createProfileModel().location,
      ),
      'published at': () => expectBidirectional(
        publishedAtMapper,
        createProfileEntity().publishedAt.first,
        createProfileModel().publishedAt.first,
      ),
      'resume': () => expectBidirectional(
        resumeMapper,
        createProfileEntity().resume,
        createProfileModel().resume,
      ),
      'social link': () => expectBidirectional(
        socialLinkMapper,
        createProfileEntity().socialLinks.first,
        createProfileModel().socialLinks.first,
      ),
      'working hours': () => expectBidirectional(
        workingHoursMapper,
        createProfileEntity().workingHours,
        createProfileModel().workingHours,
      ),
    };

    for (final entry in mapperCases.entries) {
      test(
        'should map the ${entry.key} entity and model bidirectionally',
        entry.value,
      );
    }
  });
}
