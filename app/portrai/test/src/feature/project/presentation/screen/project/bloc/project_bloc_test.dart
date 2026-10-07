import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/_bloc.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/dto/_dto.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/extension/_extension.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/external_app_handler/domain/use_case/fake_open_external_url_param.dart';
import '../../../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
import '../../../../../../../mock/feature/project/presentation/screen/project/tracking/mock_project_tracking_delegate.dart';
import '../../../../../../../mock/feature/project/test_data/project_test_data.dart';

void main() {
  final project = createProjectEntity();

  setUpAll(() => registerFallbackValue(FakeOpenExternalUrlParam()));

  group('ProjectBloc', () {
    late MockOpenExternalUrlUseCase openUrl;
    late MockProjectTrackingDelegate tracking;

    ProjectBloc buildBloc() => ProjectBloc(openUrl, tracking);

    setUp(() {
      openUrl = MockOpenExternalUrlUseCase();
      tracking = MockProjectTrackingDelegate();
    });

    blocTest<ProjectBloc, ProjectState>(
      'should emit a loaded state with generated sections when the project loads',
      build: buildBloc,
      act: (bloc) => bloc.add(LoadProjectEvent(project)),
      expect: () => [
        isA<LoadedState>()
            .having((state) => state.project, 'project', project)
            .having((state) => state.sections.length, 'sections length', 6),
      ],
    );

    blocTest<ProjectBloc, ProjectState>(
      'should open and track an availability link when the URL opens successfully',
      setUp: () =>
          openUrl.stubCall(const Right<OpenExternalUrlFailure, bool>(true)),
      build: buildBloc,
      seed: () => LoadedState(project: project, sections: project.sections),
      act: (bloc) => bloc.add(
        const OpenExternalUrlEvent(
          url: 'https://example.com/website',
          label: 'Website',
        ),
      ),
      expect: () => const <ProjectState>[],
      verify: (_) {
        verify(
          () => openUrl(
            any<OpenExternalUrlParam>(
              that: isA<OpenExternalUrlParam>().having(
                (param) => param.uri.toString(),
                'uri',
                'https://example.com/website',
              ),
            ),
          ),
        ).called(1);
        verify(() => tracking.trackAvailabilityLinkClick('Website')).called(1);
      },
    );

    blocTest<ProjectBloc, ProjectState>(
      'should not track an availability link when opening the URL fails',
      setUp: () => openUrl.stubCall(
        const Left<OpenExternalUrlFailure, bool>(OpenExternalUrlFailure()),
      ),
      build: buildBloc,
      seed: () => LoadedState(project: project, sections: project.sections),
      act: (bloc) => bloc.add(
        const OpenExternalUrlEvent(
          url: 'https://example.com/website',
          label: 'Website',
        ),
      ),
      expect: () => const <ProjectState>[],
      verify: (_) {
        verify(() => openUrl(any())).called(1);
        verifyNever(() => tracking.trackAvailabilityLinkClick(any()));
      },
    );

    blocTest<ProjectBloc, ProjectState>(
      'should not open a link when the project has not loaded',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const OpenExternalUrlEvent(
          url: 'https://example.com/website',
          label: 'Website',
        ),
      ),
      expect: () => const <ProjectState>[],
      verify: (_) => verifyNever(() => openUrl(any())),
    );

    blocTest<ProjectBloc, ProjectState>(
      'should track screen, section, content, and tab impressions when visible events arrive',
      build: buildBloc,
      act: (bloc) {
        final section = project.sections
            .whereType<ScrollableProjectSectionDTO>()
            .first;
        bloc.add(ScreenVisibleEvent());
        bloc.add(const LoadingContentViewVisibleEvent());
        bloc.add(const SuccessContentViewVisibleEvent());
        bloc.add(SectionVisibleEvent(section.trackingId));
        bloc.add(HeaderTabClickEvent(section));
      },
      expect: () => const <ProjectState>[],
      verify: (_) {
        verify(() => tracking.trackScreenView()).called(1);
        verify(() => tracking.trackLoadingContentView()).called(1);
        verify(() => tracking.trackLoadedContentView()).called(1);
        verify(
          () => tracking.trackSectionView('project_overview_section'),
        ).called(1);
        verify(
          () => tracking.trackTabItemSelection('project_overview_section'),
        ).called(1);
      },
    );
  });
}
