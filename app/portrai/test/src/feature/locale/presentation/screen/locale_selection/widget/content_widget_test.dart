import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/_bloc.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/widget/content_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

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
        verify(
          () => bloc.add(const ViewStateVisibleEvent('loading_content_view')),
        ).called(1);
      },
    );

    testWidgets(
      'should render an error card and dispatch the load event when retry is tapped',
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

        expect(find.byType(DSErrorCardWidget), findsOneWidget);
        expect(find.text('Failed to load language settings'), findsOneWidget);
        verify(
          () => bloc.add(const ViewStateVisibleEvent('error_content_view')),
        ).called(1);

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
        verify(
          () => bloc.add(const ViewStateVisibleEvent('loaded_content_view')),
        ).called(1);
      },
    );

    testWidgets(
      'should select the new locale when a loaded state follows another loaded state',
      (tester) async {
        final englishState = LocaleSelectionStateFactory.loaded(
          supportedLocales: createSupportedLocales(),
          appLocale: createEnglishLocale(),
        );
        final dutchState = LocaleSelectionStateFactory.loaded(
          supportedLocales: createSupportedLocales(),
          appLocale: createDutchLocale(),
        );
        final bloc = MockLocaleSelectionBloc()
          ..stubStateStream(
            initialState: englishState,
            states: Stream<LocaleSelectionState>.value(dutchState),
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

        final radioGroup = tester.widget<RadioGroup<Locale>>(
          find.byType(RadioGroup<Locale>),
        );
        expect(radioGroup.groupValue, const Locale('nl'));
      },
    );

    for (final isDialog in [false, true]) {
      testWidgets(
        'should ${isDialog ? 'show the languages without' : 'scroll the '
                  'languages followed by'} the footer when loaded '
        '${isDialog ? 'in' : 'outside'} a dialog',
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
              child: ScreenFooterProviderWidget(
                footer: const Text('footer'),
                child: BlocProvider<LocaleSelectionBloc>.value(
                  value: bloc,
                  child: ContentWidget(isDialog: isDialog),
                ),
              ),
            ),
          );
          await tester.pump();

          final scrollView = find.byType(CustomScrollView);
          expect(
            find.descendant(
              of: scrollView,
              matching: find.byType(RadioGroup<Locale>),
            ),
            isDialog ? findsNothing : findsOneWidget,
          );
          expect(find.byType(RadioGroup<Locale>), findsOneWidget);
          expect(
            find.text('footer', skipOffstage: false),
            isDialog ? findsNothing : findsOneWidget,
          );
          expect(find.byType(FooterWidget), findsNothing);
          expect(
            find.byType(PageAppBarWidget),
            isDialog ? findsNothing : findsOneWidget,
          );
        },
      );
    }

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
