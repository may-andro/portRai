import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

import '../../../../../mock/feature/profile/test_data/profile_test_data.dart';

void main() {
  group('Profile entities', () {
    test('should support value equality for the profile entity graph', () {
      expect(createProfileEntity(), createProfileEntity());
    });

    test('should expose all expected nested profile values', () {
      final profile = createProfileEntity();

      expect(profile.publishedAt, hasLength(2));
      expect(profile.socialLinks, hasLength(2));
      expect(profile.languages, hasLength(2));
      expect(profile.educations.single.endDate, '2015-06-30');
      expect(profile.location.coordinates.latitude, 38.3452);
      expect(profile.availability.openToRelocate, isFalse);
      expect(profile.workingHours.weekdays, isTrue);
    });

    test('should support value equality for each supporting entity', () {
      expect(
        const AvailabilityEntity(
          status: 'Available',
          workType: 'Remote',
          openToRelocate: false,
          preferredProjectDuration: '3 months',
          hourlyRate: '€75/hour',
          availability: 'Part-time',
        ),
        const AvailabilityEntity(
          status: 'Available',
          workType: 'Remote',
          openToRelocate: false,
          preferredProjectDuration: '3 months',
          hourlyRate: '€75/hour',
          availability: 'Part-time',
        ),
      );
      expect(
        const CoordinatesEntity(latitude: 1, longitude: 2),
        const CoordinatesEntity(latitude: 1, longitude: 2),
      );
      expect(
        const EducationEntity(
          institution: 'AIT',
          degree: 'BEng',
          field: 'Electronics',
          startDate: '2011-07-01',
          endDate: '2015-06-30',
          image: 'image',
          url: 'url',
          location: 'Pune',
        ),
        const EducationEntity(
          institution: 'AIT',
          degree: 'BEng',
          field: 'Electronics',
          startDate: '2011-07-01',
          endDate: '2015-06-30',
          image: 'image',
          url: 'url',
          location: 'Pune',
        ),
      );
      expect(
        const LanguageEntity(language: 'English', proficiency: 'Fluent'),
        const LanguageEntity(language: 'English', proficiency: 'Fluent'),
      );
      expect(
        const LocationEntity(
          city: 'Alicante',
          state: 'Valencian Community',
          country: 'Spain',
          timezone: 'GMT+1',
          coordinates: CoordinatesEntity(latitude: 1, longitude: 2),
        ),
        const LocationEntity(
          city: 'Alicante',
          state: 'Valencian Community',
          country: 'Spain',
          timezone: 'GMT+1',
          coordinates: CoordinatesEntity(latitude: 1, longitude: 2),
        ),
      );
      expect(
        const PublishedAtEntity(name: 'App Store', url: 'url', image: 'image'),
        const PublishedAtEntity(name: 'App Store', url: 'url', image: 'image'),
      );
      expect(
        const ResumeEntity(url: 'url', lastUpdated: '2025-10-15', image: 'img'),
        const ResumeEntity(url: 'url', lastUpdated: '2025-10-15', image: 'img'),
      );
      expect(
        const SocialLinkEntity(name: 'Github', url: 'url', image: 'image'),
        const SocialLinkEntity(name: 'Github', url: 'url', image: 'image'),
      );
      expect(
        const WorkingHoursEntity(
          timezone: 'Europe/Madrid',
          preferredHours: '09:00 - 18:00',
          weekdays: true,
          weekends: 'Limited',
        ),
        const WorkingHoursEntity(
          timezone: 'Europe/Madrid',
          preferredHours: '09:00 - 18:00',
          weekdays: true,
          weekends: 'Limited',
        ),
      );
    });
  });
}
