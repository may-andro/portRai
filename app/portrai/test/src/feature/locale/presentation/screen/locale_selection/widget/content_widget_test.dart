import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/_bloc.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/widget/content_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';

import '../../../../../../../mock/feature/locale/presentation/screen/locale_selection/bloc/mock_locale_selection_bloc.dart';
import '../../../../../../../mock/feature/locale/test_data/locale_test_data.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('LocaleSelection ContentWidget', () {
    testWidgets(
      'should render a loading indicator and dispatch the loading impression when loading',
      (tester) async {
        final bloc = MockLocaleSelectionBloc()..stubState(const LoadingState());

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<LocaleSelectionBloc>.value(
              value: bloc,
              child: const ContentWidget(isDialog: false),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DSLoadingWidget), findsOneWidget);
        verify(() => bloc.add(ViewStateVisibleEvent.loading())).called(1);
      },
    );

    testWidgets(
      'should render an error message and dispatch the retry event when retry is tapped',
      (tester) async {
        final bloc = MockLocaleSelectionBloc()
          ..stubState(const ErrorState(failure: GetLocaleUnknownFailure()));

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<LocaleSelectionBloc>.value(
              value: bloc,
              child: const ContentWidget(isDialog: false),
            ),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Failed to load language settings'), findsOneWidget);
        verify(() => bloc.add(ViewStateVisibleEvent.error())).called(1);

        await tester.tap(find.text('Retry'));
        await tester.pump();

        verify(() => bloc.add(const LoadLocaleEvent())).called(1);
      },
    );

    testWidgets(
      'should render locale options when the locale data loads successfully',
      (tester) async {
        final bloc = MockLocaleSelectionBloc()
          ..stubState(
            LocaleSelectionStateFactory.loaded(
              supportedLocales: createSupportedLocales(),
              appLocale: createEnglishLocale(),
            ),
          );

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<LocaleSelectionBloc>.value(
              value: bloc,
              child: const ContentWidget(isDialog: false),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Choose Language'), findsOneWidget);
        expect(find.text('🇬🇧 English'), findsOneWidget);
        expect(find.text('🇳🇱 Dutch'), findsOneWidget);
      },
    );

    testWidgets('should not render the footer when loaded in dialog mode', (
      tester,
    ) async {
      final bloc = MockLocaleSelectionBloc()
        ..stubState(
          LocaleSelectionStateFactory.loaded(
            supportedLocales: createSupportedLocales(),
            appLocale: createEnglishLocale(),
            profile: createLocaleProfile(),
          ),
        );

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider<LocaleSelectionBloc>.value(
            value: bloc,
            child: const ContentWidget(isDialog: true),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(FooterWidget), findsNothing);
    });

    testWidgets(
      'should dispatch an update event when a different locale option is tapped',
      (tester) async {
        final bloc = MockLocaleSelectionBloc()
          ..stubState(
            LocaleSelectionStateFactory.loaded(
              supportedLocales: createSupportedLocales(),
              appLocale: createEnglishLocale(),
            ),
          );

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<LocaleSelectionBloc>.value(
              value: bloc,
              child: const ContentWidget(isDialog: false),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(
          find.byWidgetPredicate(
            (widget) =>
                widget is Radio<Locale> && widget.value == const Locale('nl'),
          ),
        );
        await tester.pump();

        verify(() => bloc.add(const UpdateLocaleEvent(Locale('nl')))).called(1);
      },
    );
  });
}
