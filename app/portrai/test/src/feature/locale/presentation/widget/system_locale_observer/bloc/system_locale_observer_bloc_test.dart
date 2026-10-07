import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:portrai/src/feature/locale/presentation/widget/system_locale_observer/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/locale/domain/use_case/mock_get_locale_use_case.dart';
import '../../../../../../../mock/feature/locale/domain/use_case/mock_update_locale_use_case.dart';
import '../../../../../../../mock/feature/locale/test_data/locale_test_data.dart';

void main() {
  group('SystemLocaleObserverBloc', () {
    late MockGetLocaleUseCase getLocaleUseCase;
    late MockUpdateLocaleUseCase updateLocaleUseCase;

    SystemLocaleObserverBloc buildBloc() => SystemLocaleObserverBloc(
      getLocaleUseCase: getLocaleUseCase,
      updateLocaleUseCase: updateLocaleUseCase,
    );

    setUp(() {
      getLocaleUseCase = MockGetLocaleUseCase();
      updateLocaleUseCase = MockUpdateLocaleUseCase();
    });

    blocTest<SystemLocaleObserverBloc, SystemLocaleObserverState>(
      'should emit loaded when loading the initial locale succeeds',
      setUp: () {
        getLocaleUseCase.stubCall(
          Right<GetLocaleFailure, AppLocale>(createEnglishLocale()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadLocaleEvent()),
      expect: () => [LoadedState(currentLocale: createEnglishLocale())],
    );

    blocTest<SystemLocaleObserverBloc, SystemLocaleObserverState>(
      'should emit no new state when loading the initial locale fails',
      setUp: () {
        getLocaleUseCase.stubCall(
          const Left<GetLocaleFailure, AppLocale>(GetLocaleUnknownFailure()),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadLocaleEvent()),
      expect: () => const <SystemLocaleObserverState>[],
    );

    blocTest<SystemLocaleObserverBloc, SystemLocaleObserverState>(
      'should emit updating then loaded when the locale update succeeds',
      setUp: () {
        updateLocaleUseCase.stubCall(
          locale: createDutchLocale(),
          result: const Right<UpdateLocaleFailure, void>(null),
        );
      },
      build: buildBloc,
      seed: () => LoadedState(currentLocale: createEnglishLocale()),
      act: (bloc) => bloc.add(LocaleUpdateEvent(createDutchLocale())),
      expect: () => [
        LoadedState(
          currentLocale: createEnglishLocale(),
          updatingLocale: createDutchLocale(),
        ),
        LoadedState(currentLocale: createDutchLocale()),
      ],
    );

    blocTest<SystemLocaleObserverBloc, SystemLocaleObserverState>(
      'should revert to the previous locale when the locale update fails',
      setUp: () {
        updateLocaleUseCase.stubCall(
          locale: createSpanishLocale(),
          result: const Left<UpdateLocaleFailure, void>(
            UpdateLocaleUnknownFailure(),
          ),
        );
      },
      build: buildBloc,
      seed: () => LoadedState(currentLocale: createEnglishLocale()),
      act: (bloc) => bloc.add(LocaleUpdateEvent(createSpanishLocale())),
      expect: () => [
        LoadedState(
          currentLocale: createEnglishLocale(),
          updatingLocale: createSpanishLocale(),
        ),
        LoadedState(currentLocale: createEnglishLocale()),
      ],
    );

    blocTest<SystemLocaleObserverBloc, SystemLocaleObserverState>(
      'should ignore locale updates when the bloc has not finished loading',
      build: buildBloc,
      act: (bloc) => bloc.add(LocaleUpdateEvent(createSpanishLocale())),
      expect: () => const <SystemLocaleObserverState>[],
    );

    blocTest<SystemLocaleObserverBloc, SystemLocaleObserverState>(
      'should ignore locale updates when the requested locale matches the current locale',
      build: buildBloc,
      seed: () => LoadedState(currentLocale: createEnglishLocale()),
      act: (bloc) => bloc.add(LocaleUpdateEvent(createEnglishLocale())),
      expect: () => const <SystemLocaleObserverState>[],
    );
  });
}
