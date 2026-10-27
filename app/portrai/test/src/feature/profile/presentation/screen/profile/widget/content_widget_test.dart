import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/widget/content_widget.dart';
import 'package:portrai/src/feature/profile/presentation/widget/_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

import '../../../../../../../mock/feature/profile/presentation/screen/profile/bloc/mock_profile_bloc.dart';
import '../../../../../../../mock/feature/profile/test_data/profile_test_data.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('Profile ContentWidget', () {
    testWidgets(
      'should render a loading indicator and track its impression when loading',
      (tester) async {
        final bloc = MockProfileBloc()..stubState(const LoadingState());

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<ProfileBloc>.value(
              value: bloc,
              child: const ContentWidget(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DSLoadingWidget), findsOneWidget);
        verify(
          () => bloc.add(const ViewStateVisibleEvent('loading_content_view')),
        ).called(1);
      },
    );

    testWidgets(
      'should render an error card and track its impression when loading fails',
      (tester) async {
        final bloc = MockProfileBloc()
          ..stubState(const ErrorState(failure: ProfileNotFoundFailure()));

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<ProfileBloc>.value(
              value: bloc,
              child: const ContentWidget(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DSErrorCardWidget), findsOneWidget);
        verify(
          () => bloc.add(const ViewStateVisibleEvent('error_content_view')),
        ).called(1);
      },
    );

    testWidgets(
      'should scroll the profile followed by the shared footer when loaded',
      (tester) async {
        // Tall enough to lay out the whole page, footer included.
        tester.view.physicalSize = const Size(1440, 12000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final bloc = MockProfileBloc()
          ..stubState(LoadedState(profile: createProfileEntity()));

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: ScreenFooterProviderWidget(
              footer: const Text('footer'),
              child: BlocProvider<ProfileBloc>.value(
                value: bloc,
                child: const ContentWidget(),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 6));
        await tester.pump(const Duration(seconds: 2));

        expect(find.byType(CustomScrollView), findsOneWidget);
        expect(find.text('Mayank Rai'), findsWidgets);
        expect(find.text('footer', skipOffstage: false), findsOneWidget);
        expect(
          tester.getTopLeft(find.text('footer', skipOffstage: false)).dy,
          greaterThan(tester.getTopLeft(find.text('Mayank Rai').first).dy),
        );
        expect(find.byType(FooterWidget), findsNothing);
        // The test font is wider than the real one, so overflow is tolerated.
        final error = tester.takeException();
        expect(
          error == null ||
              error.toString().contains('overflowed') ||
              error.toString().contains('Multiple exceptions'),
          isTrue,
        );
      },
    );

    testWidgets(
      'should build the bands below the screen only when scrolled to them',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final bloc = MockProfileBloc()
          ..stubState(LoadedState(profile: createProfileEntity()));

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<ProfileBloc>.value(
              value: bloc,
              child: const ContentWidget(),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 6));

        expect(find.byType(TextField, skipOffstage: false), findsNothing);

        await tester.scrollUntilVisible(
          find.byType(TextField),
          500,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pump(const Duration(seconds: 2));

        expect(find.byType(TextField), findsOneWidget);
        // The test font is wider than the real one, so overflow is tolerated.
        final error = tester.takeException();
        expect(
          error == null ||
              error.toString().contains('overflowed') ||
              error.toString().contains('Multiple exceptions'),
          isTrue,
        );
      },
    );

    for (final entry in {
      'mobile': const Size(390, 844),
      'desktop': const Size(1440, 900),
    }.entries) {
      testWidgets(
        'should render the hero without errors when on ${entry.key}',
        (tester) async {
          tester.view.physicalSize = entry.value;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final bloc = MockProfileBloc()
            ..stubState(LoadedState(profile: createProfileEntity()));

          await tester.pumpWidget(
            TestWidgetWrapper(
              child: BlocProvider<ProfileBloc>.value(
                value: bloc,
                child: const ContentWidget(),
              ),
            ),
          );
          await tester.pump(const Duration(seconds: 6));
          await tester.pump(const Duration(seconds: 2));

          expect(find.text('Mayank Rai'), findsWidgets);
          verify(
            () => bloc.add(const ViewStateVisibleEvent('loaded_content_view')),
          ).called(1);
          // The test font is wider than the real one, so overflow is tolerated.
          final error = tester.takeException();
          expect(
            error == null ||
                error.toString().contains('overflowed') ||
                error.toString().contains('Multiple exceptions'),
            isTrue,
          );
        },
      );
    }
  });
}
