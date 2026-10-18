import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/expertise/expertise.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/experience/domain/use_case/mock_get_experiences_use_case.dart';
import '../../../../../mock/feature/expertise/domain/use_case/mock_get_all_expertise_use_case.dart';
import '../../../../../mock/feature/profile/domain/use_case/mock_get_profile_use_case.dart';
import '../../../../../mock/feature/project/domain/use_case/mock_get_projects_use_case.dart';
import '../../../../../util/cv_export_test_fixture.dart';

void main() {
  group('BuildCvDocumentUseCase', () {
    late MockGetProfileUseCase getProfile;
    late MockGetExperiencesUseCase getExperiences;
    late MockGetProjectsUseCase getProjects;
    late MockGetAllExpertiseUseCase getAllExpertise;
    late BuildCvDocumentUseCase useCase;

    setUp(() {
      getProfile = MockGetProfileUseCase()
        ..stubCall(
          Right<GetProfileFailure, ProfileEntity>(
            CvExportTestFixture.profile(),
          ),
        );
      getExperiences = MockGetExperiencesUseCase()
        ..stubCall(
          Right<GetExperiencesFailure, List<ExperienceEntity>>(
            CvExportTestFixture.experiences(),
          ),
        );
      getProjects = MockGetProjectsUseCase()
        ..stubCall(
          Right<GetProjectsFailure, List<ProjectEntity>>(
            CvExportTestFixture.projects(),
          ),
        );
      getAllExpertise = MockGetAllExpertiseUseCase()
        ..stubCall(
          Right<GetAllExpertiseFailure, List<ExpertiseEntity>>(
            CvExportTestFixture.expertise(),
          ),
        );
      useCase = BuildCvDocumentUseCase(
        getProfile,
        getExperiences,
        getProjects,
        getAllExpertise,
      );
    });

    Future<CvDocumentEntity> build() async => (await useCase()).right;

    test('should order experiences and projects most recent first', () async {
      final document = await build();

      expect(document.experiences.map((experience) => experience.company), [
        'Current Company',
        'Middle Company',
        'Old Company',
      ]);
      expect(document.projects.map((project) => project.title), [
        'New Project',
        'Old Project',
      ]);
    });

    test('should only list projects that have a link', () async {
      final document = await build();

      expect(document.projects.map((project) => project.url), [
        'https://new.example.com',
        'https://old.example.com',
      ]);
    });

    test('should link the website and the companies', () async {
      final document = await build();

      expect(document.websiteUrl, 'https://ada.example.com');
      expect(
        document.experiences.first.url,
        'https://currentcompany.example.com',
      );
    });

    test(
      'should leave the end date empty when the experience is current',
      () async {
        final document = await build();

        expect(document.experiences.first.endDate, isNull);
      },
    );

    test(
      'should use the achievements then responsibilities as highlights',
      () async {
        final document = await build();

        expect(document.experiences.first.highlights, [
          'Led a team of six engineers',
          'Cut build time by 40%',
          'Code reviews',
        ]);
      },
    );

    test(
      'should fall back to the description when there are no highlights',
      () async {
        final document = await build();

        expect(document.experiences[1].highlights, ['Built mobile apps.']);
      },
    );

    test(
      'should order skills from the highest level when building groups',
      () async {
        final document = await build();

        expect(document.skillGroups.single.skills, [
          'Flutter',
          'Swift',
          'Dart',
          'Kotlin',
        ]);
      },
    );

    test(
      'should include clickable contacts when the profile has them',
      () async {
        final document = await build();

        expect(document.contacts.first.text, 'ada@example.com');
        expect(document.contacts.first.url, 'mailto:ada@example.com');
        expect(
          document.contacts.map((contact) => contact.text),
          contains('github.com/ada'),
        );
      },
    );

    test(
      'should fail with data unavailable when the profile is missing',
      () async {
        getProfile.stubCall(
          const Left<GetProfileFailure, ProfileEntity>(
            ProfileNotFoundFailure(),
          ),
        );

        final result = await useCase();

        expect(result.left, isA<CvDataUnavailableFailure>());
      },
    );

    test(
      'should fail with data unavailable when the experiences fail',
      () async {
        getExperiences.stubCall(
          const Left<GetExperiencesFailure, List<ExperienceEntity>>(
            ExperiencesNotFoundFailure(),
          ),
        );

        final result = await useCase();

        expect(result.left, isA<CvDataUnavailableFailure>());
      },
    );
  });
}
