import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:portrai/src/feature/profile/data/model/_model.dart';

import '../../../../../mock/feature/profile/test_data/profile_test_data.dart';

void main() {
  group('Profile models', () {
    test('should deserialize the full profile model when JSON is valid', () {
      final model = ProfileModel.fromJson(createProfileJson());

      expect(model.fullName, 'Mayank Rai');
      expect(model.publishedAt, hasLength(2));
      expect(model.socialLinks, hasLength(2));
      expect(model.languages.first.language, 'English');
      expect(model.educations.single.endDate, '2015-06-30');
      expect(model.locale, 'en');
    });

    test(
      'should preserve all profile fields when serialized and deserialized',
      () {
        final model = createProfileModel();

        expect(ProfileModel.fromJson(model.toJson()).toJson(), model.toJson());
      },
    );

    test(
      'should reject missing required profile fields when deserializing JSON',
      () {
        final incomplete = Map<String, dynamic>.of(createProfileJson())
          ..remove('fullName');

        expect(
          () => ProfileModel.fromJson(incomplete),
          throwsA(isA<CheckedFromJsonException>()),
        );
      },
    );

    final cases = <String, Object Function(Map<String, dynamic>)>{
      'availability': (json) => AvailabilityModel.fromJson(json),
      'coordinates': (json) => CoordinatesModel.fromJson(json),
      'education': (json) => EducationModel.fromJson(json),
      'language': (json) => LanguageModel.fromJson(json),
      'location': (json) => LocationModel.fromJson(json),
      'published at': (json) => PublishedAtModel.fromJson(json),
      'resume': (json) => ResumeModel.fromJson(json),
      'social link': (json) => SocialLinkModel.fromJson(json),
      'working hours': (json) => WorkingHoursModel.fromJson(json),
    };

    final jsons = <String, Map<String, dynamic>>{
      'availability': createProfileModel().availability.toJson(),
      'coordinates': createProfileModel().location.coordinates.toJson(),
      'education': createProfileModel().educations.single.toJson(),
      'language': createProfileModel().languages.first.toJson(),
      'location': createProfileModel().location.toJson(),
      'published at': createProfileModel().publishedAt.first.toJson(),
      'resume': createProfileModel().resume.toJson(),
      'social link': createProfileModel().socialLinks.first.toJson(),
      'working hours': createProfileModel().workingHours.toJson(),
    };

    for (final entry in cases.entries) {
      test('should round-trip the ${entry.key} model when serialized', () {
        final json = jsons[entry.key]!;
        final model = entry.value(json);

        expect((model as dynamic).toJson(), json);
      });

      test(
        'should reject missing required ${entry.key} fields when deserializing JSON',
        () {
          final incomplete = Map<String, dynamic>.of(jsons[entry.key]!)
            ..remove(jsons[entry.key]!.keys.first);

          expect(
            () => entry.value(incomplete),
            throwsA(isA<CheckedFromJsonException>()),
          );
        },
      );
    }
  });
}
