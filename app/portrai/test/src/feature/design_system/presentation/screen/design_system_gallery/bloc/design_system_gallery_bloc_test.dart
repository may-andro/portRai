import 'package:bloc_test/bloc_test.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';
import 'package:portrai/src/feature/design_system/presentation/screen/design_system_gallery/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/design_system/domain/use_case/mock_apply_design_system_use_case.dart';
import '../../../../../../../mock/feature/design_system/domain/use_case/mock_select_design_system_use_case.dart';
import '../../../../../../../mock/feature/design_system/presentation/screen/design_system_gallery/tracking/mock_design_system_gallery_tracking_delegate.dart';

void main() {
  group('DesignSystemGalleryBloc', () {
    const designSystemsByMonth = [
      DesignSystem.hogmanay,
      DesignSystem.carnival,
      DesignSystem.holi,
      DesignSystem.sakura,
      DesignSystem.beltane,
      DesignSystem.hogeras,
      DesignSystem.obon,
      DesignSystem.pachamama,
      DesignSystem.chuseok,
      DesignSystem.halloween,
      DesignSystem.diwali,
      DesignSystem.xmas,
    ];
    const loadedState = DesignSystemGalleryLoadedState(
      designSystems: designSystemsByMonth,
      appliedDesignSystem: DesignSystem.holi,
      monthlyDesignSystem: DesignSystem.halloween,
      previewedDesignSystem: DesignSystem.holi,
    );

    late MockSelectDesignSystemUseCase selectDesignSystemUseCase;
    late MockApplyDesignSystemUseCase applyDesignSystemUseCase;
    late MockDesignSystemGalleryTrackingDelegate trackingDelegate;

    setUp(() {
      selectDesignSystemUseCase = MockSelectDesignSystemUseCase()
        ..stubCall(DesignSystem.halloween);
      applyDesignSystemUseCase = MockApplyDesignSystemUseCase()
        ..registerFallbacks()
        ..stubCall(const Left(ApplyDesignSystemUnknownFailure()));
      trackingDelegate = MockDesignSystemGalleryTrackingDelegate();
    });

    DesignSystemGalleryBloc buildBloc() => DesignSystemGalleryBloc(
      DesignSystem.holi,
      selectDesignSystemUseCase,
      applyDesignSystemUseCase,
      trackingDelegate,
    );

    blocTest<DesignSystemGalleryBloc, DesignSystemGalleryState>(
      'should list the design systems in month order and preview the applied '
      'one when loaded',
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadDesignSystemGalleryEvent()),
      expect: () => const [loadedState],
    );

    blocTest<DesignSystemGalleryBloc, DesignSystemGalleryState>(
      'should preview the design system and track it when a card comes to '
      'the front',
      build: buildBloc,
      seed: () => loadedState,
      act: (bloc) =>
          bloc.add(const PreviewDesignSystemClickEvent(DesignSystem.obon)),
      expect: () => [
        loadedState.copyWith(previewedDesignSystem: DesignSystem.obon),
      ],
      verify: (_) =>
          verify(() => trackingDelegate.trackPreview(DesignSystem.obon)),
    );

    blocTest<DesignSystemGalleryBloc, DesignSystemGalleryState>(
      'should ignore a preview of the design system already shown',
      build: buildBloc,
      seed: () => loadedState,
      act: (bloc) =>
          bloc.add(const PreviewDesignSystemClickEvent(DesignSystem.holi)),
      expect: () => const <DesignSystemGalleryState>[],
      verify: (_) => verifyNever(() => trackingDelegate.trackPreview(any())),
    );

    blocTest<DesignSystemGalleryBloc, DesignSystemGalleryState>(
      'should not apply when the previewed design system is already in use',
      build: buildBloc,
      seed: () => loadedState,
      act: (bloc) => bloc.add(const ApplyDesignSystemClickEvent()),
      expect: () => const <DesignSystemGalleryState>[],
      verify: (_) => verifyNever(() => applyDesignSystemUseCase(any())),
    );

    blocTest<DesignSystemGalleryBloc, DesignSystemGalleryState>(
      'should show the failure and keep the preview when applying fails',
      build: buildBloc,
      seed: () =>
          loadedState.copyWith(previewedDesignSystem: DesignSystem.sakura),
      act: (bloc) => bloc.add(const ApplyDesignSystemClickEvent()),
      expect: () => [
        loadedState.copyWith(
          previewedDesignSystem: DesignSystem.sakura,
          isApplying: true,
        ),
        loadedState.copyWith(
          previewedDesignSystem: DesignSystem.sakura,
          isApplying: false,
          failure: const ApplyDesignSystemUnknownFailure(),
        ),
      ],
      verify: (_) {
        verify(() => applyDesignSystemUseCase(DesignSystem.sakura)).called(1);
        verify(() => trackingDelegate.trackApply(DesignSystem.sakura));
      },
    );

    blocTest<DesignSystemGalleryBloc, DesignSystemGalleryState>(
      'should track a screen view when the screen is shown',
      build: buildBloc,
      act: (bloc) => bloc.add(const ScreenVisibleEvent()),
      verify: (_) => verify(() => trackingDelegate.trackScreenView()),
    );
  });
}
