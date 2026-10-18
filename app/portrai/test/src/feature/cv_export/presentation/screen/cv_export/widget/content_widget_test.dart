import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/bloc/_bloc.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/widget/content_widget.dart';

import '../../../../../../../mock/feature/cv_export/presentation/screen/cv_export/bloc/mock_cv_export_bloc.dart';
import '../../../../../../../util/cv_export_test_fixture.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  setUpAll(() => registerFallbackValue(FakeCvExportEvent()));

  group('CV export ContentWidget', () {
    late MockCvExportBloc bloc;
    late CvExportLoadedState state;

    setUp(() {
      state = CvExportLoadedState(
        document: CvExportTestFixture.lightDocument(),
        options: const CvOptionsEntity(),
        labels: CvExportTestFixture.labels,
      );
    });

    Future<void> pumpContent(
      WidgetTester tester, {
      Size size = const Size(1000, 3000),
    }) async {
      bloc = MockCvExportBloc()..stubState(state);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider<CvExportBloc>.value(
            value: bloc,
            child: ContentWidget(state: state),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      'should dispatch the template event when a template is tapped',
      (tester) async {
        await pumpContent(tester);

        await tester.tap(find.text('Bold'));

        verify(
          () => bloc.add(const SelectCvTemplateClickEvent(CvTemplate.bold)),
        ).called(1);
      },
    );

    testWidgets('should dispatch the photo event when the switch is toggled', (
      tester,
    ) async {
      await pumpContent(tester);

      await tester.tap(find.text('Include photo'));

      verify(
        () => bloc.add(const ToggleCvPhotoClickEvent(isIncluded: true)),
      ).called(1);
    });

    testWidgets('should dispatch the section event when a section is tapped', (
      tester,
    ) async {
      await pumpContent(tester);

      await tester.tap(find.widgetWithText(SwitchListTile, 'Skills'));

      verify(
        () => bloc.add(const ToggleCvSectionClickEvent(CvSection.skills)),
      ).called(1);
    });

    testWidgets('should not dispatch download when no pdf is ready', (
      tester,
    ) async {
      await pumpContent(tester);

      await tester.tap(find.text('Download CV'), warnIfMissed: false);

      verifyNever(() => bloc.add(const DownloadCvClickEvent()));
    });

    testWidgets('should show every template without overflow on a phone', (
      tester,
    ) async {
      await pumpContent(tester, size: const Size(360, 900));

      for (final label in ['Sidebar', 'Classic', 'Minimal', 'Bold']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('should show the download action in the header and bottom', (
      tester,
    ) async {
      await pumpContent(tester);

      expect(find.byIcon(Icons.download_rounded), findsNWidgets(2));
    });
  });
}
