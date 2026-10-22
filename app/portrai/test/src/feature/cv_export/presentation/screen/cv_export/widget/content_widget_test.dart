import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/bloc/_bloc.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/widget/content_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../../../mock/feature/cv_export/presentation/screen/cv_export/bloc/mock_cv_export_bloc.dart';
import '../../../../../../../util/cv_export_test_fixture.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  setUpAll(() => registerFallbackValue(FakeCvExportEvent()));
  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

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

    Future<void> pumpChild(
      WidgetTester tester,
      Widget child, {
      Size size = const Size(1000, 3000),
      CvExportState? blocState,
    }) async {
      bloc = MockCvExportBloc()..stubState(blocState ?? state);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider<CvExportBloc>.value(value: bloc, child: child),
        ),
      );
      await tester.pump();
    }

    Future<void> pumpContent(
      WidgetTester tester, {
      Size size = const Size(1000, 3000),
    }) async {
      await pumpChild(
        tester,
        CustomScrollView(slivers: [ContentWidget(state: state)]),
        size: size,
      );
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

      await tester.tap(find.widgetWithText(FilterChip, 'Skills'));

      verify(
        () => bloc.add(const ToggleCvSectionClickEvent(CvSection.skills)),
      ).called(1);
    });

    testWidgets('should not dispatch download when no pdf is ready', (
      tester,
    ) async {
      await pumpChild(tester, const DownloadButtonWidget());

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

    testWidgets('should show the download button when the CV is loaded', (
      tester,
    ) async {
      await pumpChild(tester, const DownloadButtonWidget());

      expect(find.text('Download CV'), findsOneWidget);
    });

    testWidgets(
      'should dispatch download when the button is tapped and the pdf is ready',
      (tester) async {
        state = CvExportLoadedState(
          document: CvExportTestFixture.lightDocument(),
          options: const CvOptionsEntity(),
          labels: CvExportTestFixture.labels,
          pdfBytes: Uint8List(1),
        );
        await pumpChild(tester, const DownloadButtonWidget());

        await tester.tap(find.text('Download CV'));

        verify(() => bloc.add(const DownloadCvClickEvent())).called(1);
      },
    );

    testWidgets('should hide the download button when the CV is not loaded', (
      tester,
    ) async {
      await pumpChild(
        tester,
        const DownloadButtonWidget(),
        blocState: const CvExportInitialState(),
      );

      expect(find.text('Download CV'), findsNothing);
    });

    testWidgets('should say which job a tailored CV is for', (tester) async {
      state = CvExportLoadedState(
        document: CvExportTestFixture.lightDocument(),
        options: const CvOptionsEntity(),
        labels: CvExportTestFixture.labels,
        tailoringTarget: const CvTailoringTargetEntity(
          title: 'Senior Flutter Developer',
          company: 'Acme',
          description: '',
        ),
      );
      await pumpContent(tester);

      expect(
        find.text('Tailored for Senior Flutter Developer at Acme'),
        findsOneWidget,
      );
    });

    testWidgets('should explain the standard CV when tailoring failed', (
      tester,
    ) async {
      state = CvExportLoadedState(
        document: CvExportTestFixture.lightDocument(),
        options: const CvOptionsEntity(),
        labels: CvExportTestFixture.labels,
        tailoringFailure: const CvTailoringQuotaFailure(),
      );
      await pumpContent(tester);

      expect(find.text('Showing your standard CV'), findsOneWidget);
      expect(
        find.text(
          'You have reached the limit for tailored CVs. Try again later.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should show no tailoring banner for the standard CV', (
      tester,
    ) async {
      await pumpContent(tester);

      expect(find.textContaining('Tailored for'), findsNothing);
      expect(find.text('Showing your standard CV'), findsNothing);
    });
  });
}
