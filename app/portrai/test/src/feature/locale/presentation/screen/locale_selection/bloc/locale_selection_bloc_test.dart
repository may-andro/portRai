import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/locale/domain/use_case/mock_get_locale_use_case.dart';
import '../../../../../../../mock/feature/locale/domain/use_case/mock_update_locale_use_case.dart';
import '../../../../../../../mock/feature/locale/presentation/screen/locale_selection/tracking/mock_locale_selection_tracking_delegate.dart';
import '../../../../../../../mock/feature/locale/test_data/locale_test_data.dart';
import '../../../../../../../mock/feature/profile/domain/use_case/mock_get_profile_use_case.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const Locale('en'));
  });

  group('LocaleSelectionBloc', () {
    late MockGetLocaleUseCase getLocaleUseCase;
    late MockUpdateLocaleUseCase updateLocaleUseCase;
    late MockGetProfileUseCase getProfileUseCase;
    late MockLocaleSelectionTrackingDelegate trackingDelegate;

    LocaleSelectionBloc buildBloc() => LocaleSelectionBloc(
      getLocaleUseCase,
      updateLocaleUseCase,
      getProfileUseCase,
      trackingDelegate,
    );

    setUp(() {
      getLocaleUseCase = MockGetLocaleUseCase();
      updateLocaleUseCase = MockUpdateLocaleUseCase();
      getProfileUseCase = MockGetProfileUseCase();
      trackingDelegate = MockLocaleSelectionTrackingDelegate();
    });

    blocTest<LocaleSelectionBloc, LocaleSelectionState>(
      'should emit loaded with profile when loading the locale succeeds',
      setUp: () {
        getProfileUseCase.stubCall(
          Right<GetProfileFailure, ProfileEntity>(createLocaleProfile()),
        );
        getLocaleUseCase.stubCall(
          Right<GetLocaleFailure, AppLocale>(createEnglishLocale()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadLocaleEvent()),
      expect: () => [
        const LoadingState(),
        isA<LocaleSelectionLoadedState>()
            .having(
              (state) => state.appLocale,
              'appLocale',
              createEnglishLocale(),
            )
            .having((state) => state.profile, 'profile', isNotNull)
            .having(
              (state) => state.supportedLocales,
              'supportedLocales',
              AppLocalizations.supportedLocales,
            ),
      ],
    );

    blocTest<LocaleSelectionBloc, LocaleSelectionState>(
      'should emit loaded without profile when loading the profile fails',
      setUp: () {
        getProfileUseCase.stubCall(
          const Left<GetProfileFailure, ProfileEntity>(ProfileUnknownFailure()),
        );
        getLocaleUseCase.stubCall(
          Right<GetLocaleFailure, AppLocale>(createDutchLocale()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadLocaleEvent()),
      expect: () => [
        const LoadingState(),
        isA<LocaleSelectionLoadedState>()
            .having(
              (state) => state.appLocale,
              'appLocale',
              createDutchLocale(),
            )
            .having((state) => state.profile, 'profile', isNull),
      ],
    );

    blocTest<LocaleSelectionBloc, LocaleSelectionState>(
      'should emit error when loading the locale fails',
      setUp: () {
        getProfileUseCase.stubCall(
          Right<GetProfileFailure, ProfileEntity>(createLocaleProfile()),
        );
        getLocaleUseCase.stubCall(
          const Left<GetLocaleFailure, AppLocale>(GetLocaleUnknownFailure()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadLocaleEvent()),
      expect: () => [
        const LoadingState(),
        isA<ErrorState>().having(
          (state) => state.failure,
          'failure',
          isA<GetLocaleUnknownFailure>(),
        ),
      ],
    );

    blocTest<LocaleSelectionBloc, LocaleSelectionState>(
      'should emit updating then loaded with the preserved profile when updating the locale succeeds',
      setUp: () {
        updateLocaleUseCase.stubCall(
          locale: createDutchLocale(),
          result: const Right<UpdateLocaleFailure, void>(null),
        );
      },
      build: buildBloc,
      seed: () => LocaleSelectionStateFactory.loaded(
        supportedLocales: createSupportedLocales(),
        appLocale: createEnglishLocale(),
        profile: createLocaleProfile(),
      ),
      act: (bloc) => bloc.add(const UpdateLocaleEvent(Locale('nl'))),
      expect: () => [
        isA<LocaleSelectionUpdatingState>()
            .having(
              (state) => state.targetLocale,
              'targetLocale',
              createDutchLocale(),
            )
            .having((state) => state.profile, 'profile', isNotNull),
        isA<LocaleSelectionLoadedState>()
            .having(
              (state) => state.appLocale,
              'appLocale',
              createDutchLocale(),
            )
            .having((state) => state.profile, 'profile', isNotNull),
      ],
      verify: (_) {
        verify(
          () => trackingDelegate.trackLocaleSelectionClick('nl'),
        ).called(1);
        verify(
          () => trackingDelegate.trackLanguageUpdate(
            previousLanguage: 'en',
            newLanguage: 'nl',
          ),
        ).called(1);
      },
    );

    blocTest<LocaleSelectionBloc, LocaleSelectionState>(
      'should emit update failure with the preserved profile when updating the locale fails',
      setUp: () {
        updateLocaleUseCase.stubCall(
          locale: createSpanishLocale(),
          result: const Left<UpdateLocaleFailure, void>(
            UpdateLocaleUnknownFailure(),
          ),
        );
      },
      build: buildBloc,
      seed: () => LocaleSelectionStateFactory.loaded(
        supportedLocales: createSupportedLocales(),
        appLocale: createEnglishLocale(),
        profile: createLocaleProfile(),
      ),
      act: (bloc) => bloc.add(const UpdateLocaleEvent(Locale('es'))),
      expect: () => [
        isA<LocaleSelectionUpdatingState>()
            .having(
              (state) => state.targetLocale,
              'targetLocale',
              createSpanishLocale(),
            )
            .having((state) => state.profile, 'profile', isNotNull),
        isA<LocaleSelectionUpdateFailureState>()
            .having(
              (state) => state.targetLocale,
              'targetLocale',
              createSpanishLocale(),
            )
            .having((state) => state.profile, 'profile', isNotNull),
      ],
      verify: (_) {
        verify(
          () => trackingDelegate.trackLocaleSelectionClick('es'),
        ).called(1);
        verifyNever(
          () => trackingDelegate.trackLanguageUpdate(
            previousLanguage: any(named: 'previousLanguage'),
            newLanguage: any(named: 'newLanguage'),
          ),
        );
      },
    );

    blocTest<LocaleSelectionBloc, LocaleSelectionState>(
      'should ignore locale updates when there is no loaded data state',
      build: buildBloc,
      act: (bloc) => bloc.add(const UpdateLocaleEvent(Locale('nl'))),
      expect: () => const <LocaleSelectionState>[],
      verify: (_) =>
          verifyNever(() => trackingDelegate.trackLocaleSelectionClick(any())),
    );

    blocTest<LocaleSelectionBloc, LocaleSelectionState>(
      'should forward screen and view tracking events when visibility events arrive',
      build: buildBloc,
      act: (bloc) {
        bloc.add(const ScreenVisibleEvent(true));
        bloc.add(ViewStateVisibleEvent.loading());
        bloc.add(ViewStateVisibleEvent.success());
        bloc.add(ViewStateVisibleEvent.error());
      },
      expect: () => const <LocaleSelectionState>[],
      verify: (_) {
        verify(() => trackingDelegate.trackVisibleScreen(true)).called(1);
        verify(
          () => trackingDelegate.trackViewEvent('loading_content_view'),
        ).called(1);
        verify(
          () => trackingDelegate.trackViewEvent('loaded_content_view'),
        ).called(1);
        verify(
          () => trackingDelegate.trackViewEvent('error_content_view'),
        ).called(1);
      },
    );
  });
}
