import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/bloc/_bloc.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/cv_export_screen.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/widget/content_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';
import 'package:use_case/use_case.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../../mock/feature/cv_export/presentation/screen/cv_export/bloc/mock_cv_export_bloc.dart';
import '../../../../../../util/cv_export_test_fixture.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  setUpAll(() => registerFallbackValue(FakeCvExportEvent()));

  group('CvExportScreen', () {
    late MockCvExportBloc bloc;

    setUp(() async {
      VisibilityDetectorController.instance.updateInterval = Duration.zero;
      await appServiceLocator.reset();
    });

    tearDown(() async {
      await appServiceLocator.reset();
    });

    Future<void> pumpScreen(WidgetTester tester, CvExportState state) async {
      bloc = MockCvExportBloc()..stubState(state);
      appServiceLocator.registerFactory<CvExportBloc>(() => bloc);
      tester.view.physicalSize = const Size(1000, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: ScreenFooterProviderWidget(
            footer: Text('footer'),
            child: CvExportScreen(),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('should dispatch the load event when the screen opens', (
      tester,
    ) async {
      await pumpScreen(tester, const CvExportInitialState());

      verify(() => bloc.add(any(that: isA<LoadCvExportEvent>()))).called(1);
    });

    testWidgets('should show the loader when loading starts', (tester) async {
      await pumpScreen(tester, const CvExportInitialState());

      expect(find.byType(DSLoadingWidget), findsOneWidget);
      expect(find.text('Tailoring your CV for this job…'), findsNothing);
    });

    testWidgets(
      'should show the loader without a message when the CV is loading',
      (tester) async {
        await pumpScreen(tester, const CvExportLoadingState());

        expect(find.byType(DSLoadingWidget), findsOneWidget);
        expect(find.text('Tailoring your CV for this job…'), findsNothing);
      },
    );

    testWidgets(
      'should show the tailoring message when the CV is being tailored',
      (tester) async {
        await pumpScreen(tester, const CvExportLoadingState(isTailoring: true));

        expect(find.byType(DSLoadingWidget), findsOneWidget);
        expect(find.text('Tailoring your CV for this job…'), findsOneWidget);
      },
    );

    testWidgets('should show the error card when loading fails', (
      tester,
    ) async {
      await pumpScreen(tester, const CvExportErrorState(UnknownFailure()));

      expect(find.byType(DSErrorCardWidget), findsOneWidget);
    });

    testWidgets('should reload the CV when retry is tapped', (tester) async {
      await pumpScreen(tester, const CvExportErrorState(UnknownFailure()));

      tester
          .widget<DSErrorCardWidget>(find.byType(DSErrorCardWidget))
          .onRetryClicked!();

      verify(() => bloc.add(any(that: isA<LoadCvExportEvent>()))).called(2);
    });

    testWidgets(
      'should scroll the CV content followed by the footer when loading '
      'succeeds',
      (tester) async {
        await pumpScreen(
          tester,
          CvExportLoadedState(
            document: CvExportTestFixture.lightDocument(),
            options: const CvOptionsEntity(),
            labels: CvExportTestFixture.labels,
          ),
        );

        final scrollView = find.byType(CustomScrollView);
        expect(
          find.descendant(of: scrollView, matching: find.byType(ContentWidget)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: scrollView, matching: find.text('footer')),
          findsOneWidget,
        );
        expect(find.byType(FooterWidget), findsNothing);
        expect(find.text('Download CV'), findsOneWidget);
      },
    );

    testWidgets('should hide the download button when loading fails', (
      tester,
    ) async {
      await pumpScreen(tester, const CvExportErrorState(UnknownFailure()));

      expect(find.text('Download CV'), findsNothing);
    });
  });
}
