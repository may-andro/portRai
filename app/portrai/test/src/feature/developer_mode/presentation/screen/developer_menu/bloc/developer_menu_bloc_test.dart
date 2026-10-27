import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/ai_image_gen.dart';
import 'package:portrai/src/feature/asset_source/asset_source.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/ai_image_gen/domain/use_case/mock_get_ai_image_settings_use_case.dart';
import '../../../../../../../mock/feature/ai_image_gen/domain/use_case/mock_update_ai_image_settings_use_case.dart';
import '../../../../../../../mock/feature/asset_source/domain/use_case/mock_get_asset_source_use_case.dart';
import '../../../../../../../mock/feature/asset_source/domain/use_case/mock_update_asset_source_use_case.dart';
import '../../../../../../../mock/feature/developer_mode/presentation/screen/developer_menu/tracking/mock_developer_menu_tracking_delegate.dart';

void main() {
  group('DeveloperMenuBloc', () {
    late MockDeveloperMenuTrackingDelegate trackingDelegate;

    late MockGetAssetSourceUseCase getAssetSourceUseCase;
    late MockUpdateAssetSourceUseCase updateAssetSourceUseCase;
    late MockGetAiImageSettingsUseCase getAiImageSettingsUseCase;
    late MockUpdateAiImageSettingsUseCase updateAiImageSettingsUseCase;

    DeveloperMenuBloc buildBloc() => DeveloperMenuBloc(
      trackingDelegate,
      getAssetSourceUseCase,
      updateAssetSourceUseCase,
      getAiImageSettingsUseCase,
      updateAiImageSettingsUseCase,
    );

    setUp(() {
      trackingDelegate = MockDeveloperMenuTrackingDelegate();
      getAssetSourceUseCase = MockGetAssetSourceUseCase()
        ..stubCall(AssetSource.real);
      updateAssetSourceUseCase = MockUpdateAssetSourceUseCase()
        ..registerFallbacks()
        ..stubCall(const Right(null));
      getAiImageSettingsUseCase = MockGetAiImageSettingsUseCase()
        ..stubCall(const AiImageSettings());
      updateAiImageSettingsUseCase = MockUpdateAiImageSettingsUseCase()
        ..registerFallbacks()
        ..stubCall(const Right(null));
    });

    blocTest<DeveloperMenuBloc, DeveloperMenuState>(
      'should emit a loaded state when loading the menu',
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadDeveloperMenuEvent()),
      expect: () => const [DeveloperMenuLoadedState()],
    );

    blocTest<DeveloperMenuBloc, DeveloperMenuState>(
      'should emit a loaded state with the stored source when loading the menu and source is template',
      setUp: () => getAssetSourceUseCase.stubCall(AssetSource.template),
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadDeveloperMenuEvent()),
      expect: () => const [
        DeveloperMenuLoadedState(assetSource: AssetSource.template),
      ],
    );

    blocTest<DeveloperMenuBloc, DeveloperMenuState>(
      'should update the source and emit a loaded state when the asset source is clicked',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const AssetSourceClickEvent(AssetSource.template)),
      expect: () => const [
        DeveloperMenuLoadedState(assetSource: AssetSource.template),
      ],
      verify: (_) {
        verify(() => updateAssetSourceUseCase(AssetSource.template)).called(1);
      },
    );

    blocTest<DeveloperMenuBloc, DeveloperMenuState>(
      'should not emit a state change when updating the asset source fails',
      setUp: () => updateAssetSourceUseCase.stubCall(
        const Left(UpdateAssetSourceUnknownFailure()),
      ),
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const AssetSourceClickEvent(AssetSource.template)),
      expect: () => const <DeveloperMenuState>[],
    );

    blocTest<DeveloperMenuBloc, DeveloperMenuState>(
      'should not emit a state change when crash simulation events are added',
      build: buildBloc,
      act: (bloc) {
        bloc.add(const ForceFatalCrashEvent());
        bloc.add(const ForceNonFatalCrashEvent());
        bloc.add(const ForceBlacklistErrorEvent());
      },
      expect: () => const <DeveloperMenuState>[],
    );

    blocTest<DeveloperMenuBloc, DeveloperMenuState>(
      'should track the screen and content impressions when visible events arrive',
      build: buildBloc,
      act: (bloc) {
        bloc.add(const ScreenVisibleEvent());
        bloc.add(const ViewStateVisibleEvent('loading_content_view'));
        bloc.add(const ViewStateVisibleEvent('loaded_content_view'));
        bloc.add(const ViewStateVisibleEvent('error_content_view'));
      },
      expect: () => const <DeveloperMenuState>[],
      verify: (_) {
        verify(() => trackingDelegate.trackScreenView()).called(1);
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

    for (final label in ['feature_flags_row', 'tracking_viewer_row']) {
      blocTest<DeveloperMenuBloc, DeveloperMenuState>(
        'should track the $label entry without changing the state when it is '
        'tapped',
        build: buildBloc,
        act: (bloc) => bloc.add(DeveloperMenuEntryClickEvent(label)),
        expect: () => const <DeveloperMenuState>[],
        verify: (_) =>
            verify(() => trackingDelegate.trackEntryClick(label)).called(1),
      );
    }
  });
}
