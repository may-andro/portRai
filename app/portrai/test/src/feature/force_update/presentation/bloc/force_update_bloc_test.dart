import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/external_app_handler/domain/_domain.dart';
import 'package:portrai/src/feature/force_update/domain/_domain.dart';
import 'package:portrai/src/feature/force_update/presentation/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/external_app_handler/domain/use_case/fake_open_external_url_param.dart';
import '../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
import '../../../../../mock/feature/force_update/domain/use_case/mock_get_app_store_url_use_case.dart';
import '../../../../../mock/feature/force_update/domain/use_case/mock_is_app_update_required_use_case.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(FakeOpenExternalUrlParam());
  });

  group('ForceUpdateBloc', () {
    late MockIsAppUpdateRequiredUseCase isAppUpdateRequiredUseCase;
    late MockGetAppStoreUrlUseCase getAppStoreUrlUseCase;
    late MockOpenExternalUrlUseCase openExternalUrlUseCase;

    ForceUpdateBloc buildBloc() {
      return ForceUpdateBloc(
        isAppUpdateRequiredUseCase: isAppUpdateRequiredUseCase,
        getAppStoreUrlUseCase: getAppStoreUrlUseCase,
        openExternalUrlUseCase: openExternalUrlUseCase,
      );
    }

    setUp(() {
      isAppUpdateRequiredUseCase = MockIsAppUpdateRequiredUseCase();
      getAppStoreUrlUseCase = MockGetAppStoreUrlUseCase();
      openExternalUrlUseCase = MockOpenExternalUrlUseCase();
    });

    test('initial state is ForceUpdateInitialState', () {
      expect(buildBloc().state, const ForceUpdateInitialState());
    });

    blocTest<ForceUpdateBloc, ForceUpdateState>(
      'emits [ForceUpdateRequiredState] when update is required',
      setUp: () => isAppUpdateRequiredUseCase.stubCall(
        const Right<IsAppUpdateRequiredFailure, bool>(true),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const CheckForceUpdateEvent()),
      expect: () => const [ForceUpdateRequiredState()],
    );

    blocTest<ForceUpdateBloc, ForceUpdateState>(
      'emits [ForceUpdateNotRequiredState] when update is not required',
      setUp: () => isAppUpdateRequiredUseCase.stubCall(
        const Right<IsAppUpdateRequiredFailure, bool>(false),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const CheckForceUpdateEvent()),
      expect: () => const [ForceUpdateNotRequiredState()],
    );

    blocTest<ForceUpdateBloc, ForceUpdateState>(
      'emits [ForceUpdateNotRequiredState] (fails open) when the check fails',
      setUp: () => isAppUpdateRequiredUseCase.stubCall(
        const Left<IsAppUpdateRequiredFailure, bool>(
          IsAppUpdateRequiredUnknownFailure(cause: 'boom'),
        ),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const CheckForceUpdateEvent()),
      expect: () => const [ForceUpdateNotRequiredState()],
    );

    blocTest<ForceUpdateBloc, ForceUpdateState>(
      'emits [ForceUpdateLaunchFailedState] when the store url can not be built',
      setUp: () => getAppStoreUrlUseCase.stubCall(
        const Left<GetAppStoreUrlFailure, Uri>(
          GetAppStoreUrlUnknownFailure(cause: 'boom'),
        ),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const UpdateNowClickEvent()),
      expect: () => [
        isA<ForceUpdateLaunchFailedState>().having(
          (state) => state.failure,
          'failure',
          isA<GetAppStoreUrlUnknownFailure>(),
        ),
      ],
      verify: (_) {
        verifyNever(() => openExternalUrlUseCase(any<OpenExternalUrlParam>()));
      },
    );

    blocTest<ForceUpdateBloc, ForceUpdateState>(
      'emits [ForceUpdateLaunchFailedState] when the store url can not be opened',
      setUp: () {
        final storeUrl = Uri.parse('https://play.google.com/store/apps');
        getAppStoreUrlUseCase.stubCall(
          Right<GetAppStoreUrlFailure, Uri>(storeUrl),
        );
        openExternalUrlUseCase.stubCall(
          const Left<OpenExternalUrlFailure, bool>(
            OpenExternalUrlFailure(cause: 'launch failed'),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const UpdateNowClickEvent()),
      expect: () => [
        isA<ForceUpdateLaunchFailedState>().having(
          (state) => state.failure,
          'failure',
          isA<OpenExternalUrlFailure>(),
        ),
      ],
    );

    blocTest<ForceUpdateBloc, ForceUpdateState>(
      'opens the store url and emits nothing when it succeeds',
      setUp: () {
        final storeUrl = Uri.parse('https://play.google.com/store/apps');
        getAppStoreUrlUseCase.stubCall(
          Right<GetAppStoreUrlFailure, Uri>(storeUrl),
        );
        openExternalUrlUseCase.stubCall(
          const Right<OpenExternalUrlFailure, bool>(true),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const UpdateNowClickEvent()),
      expect: () => const <ForceUpdateState>[],
      verify: (_) {
        verify(
          () => openExternalUrlUseCase(
            any<OpenExternalUrlParam>(
              that: isA<OpenExternalUrlParam>().having(
                (param) => param.uri.toString(),
                'uri',
                'https://play.google.com/store/apps',
              ),
            ),
          ),
        ).called(1);
      },
    );
  });
}
