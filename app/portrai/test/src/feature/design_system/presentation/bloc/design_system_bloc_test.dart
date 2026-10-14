import 'package:bloc_test/bloc_test.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';
import 'package:portrai/src/feature/design_system/presentation/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/design_system/domain/use_case/mock_get_design_system_use_case.dart';
import '../../../../../mock/feature/design_system/domain/use_case/mock_reset_design_system_use_case.dart';
import '../../../../../mock/feature/design_system/domain/use_case/mock_set_design_system_use_case.dart';

void main() {
  group('DesignSystemBloc', () {
    late MockGetDesignSystemUseCase getDesignSystemUseCase;
    late MockSetDesignSystemUseCase setDesignSystemUseCase;
    late MockResetDesignSystemUseCase resetDesignSystemUseCase;

    setUp(() {
      getDesignSystemUseCase = MockGetDesignSystemUseCase()
        ..stubCall(DesignSystem.xmas);
      setDesignSystemUseCase = MockSetDesignSystemUseCase()
        ..registerFallbacks()
        ..stubCall(const Right(null));
      resetDesignSystemUseCase = MockResetDesignSystemUseCase()
        ..stubCall(const Right(null));
    });

    DesignSystemBloc buildBloc() => DesignSystemBloc(
      getDesignSystemUseCase,
      setDesignSystemUseCase,
      resetDesignSystemUseCase,
    );

    blocTest<DesignSystemBloc, DesignSystemState>(
      'should load the cached design system when initialized',
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadDesignSystemEvent()),
      expect: () => const [
        DesignSystemState(isLoaded: true, designSystem: DesignSystem.xmas),
      ],
    );

    blocTest<DesignSystemBloc, DesignSystemState>(
      'should load automatic selection when no design system is cached',
      setUp: () => getDesignSystemUseCase.stubCall(null),
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadDesignSystemEvent()),
      expect: () => const [DesignSystemState(isLoaded: true)],
    );

    blocTest<DesignSystemBloc, DesignSystemState>(
      'should save the selected design system when clicked',
      build: buildBloc,
      act: (bloc) => bloc.add(const DesignSystemClickEvent(DesignSystem.holi)),
      expect: () => const [
        DesignSystemState(
          isLoaded: true,
          designSystem: DesignSystem.holi,
          isRestartRequired: true,
        ),
      ],
      verify: (_) =>
          verify(() => setDesignSystemUseCase(DesignSystem.holi)).called(1),
    );

    blocTest<DesignSystemBloc, DesignSystemState>(
      'should propagate the set failure and keep the selection when saving fails',
      setUp: () => setDesignSystemUseCase.stubCall(
        const Left(SetDesignSystemUnknownFailure()),
      ),
      seed: () => const DesignSystemState(
        isLoaded: true,
        designSystem: DesignSystem.xmas,
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const DesignSystemClickEvent(DesignSystem.holi)),
      expect: () => const [
        DesignSystemState(
          isLoaded: true,
          designSystem: DesignSystem.xmas,
          failure: SetDesignSystemUnknownFailure(),
        ),
      ],
    );

    blocTest<DesignSystemBloc, DesignSystemState>(
      'should clear the selection when reset is clicked',
      seed: () => const DesignSystemState(
        isLoaded: true,
        designSystem: DesignSystem.holi,
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const DesignSystemResetClickEvent()),
      expect: () => const [
        DesignSystemState(isLoaded: true, shouldRestartApp: true),
      ],
      verify: (_) => verify(() => resetDesignSystemUseCase()).called(1),
    );

    blocTest<DesignSystemBloc, DesignSystemState>(
      'should not require a restart when the selected design system is unchanged',
      seed: () => const DesignSystemState(
        isLoaded: true,
        designSystem: DesignSystem.holi,
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const DesignSystemClickEvent(DesignSystem.holi)),
      expect: () => const <DesignSystemState>[],
    );

    blocTest<DesignSystemBloc, DesignSystemState>(
      'should preserve the restart requirement when a later update fails',
      setUp: () => setDesignSystemUseCase.stubCall(
        const Left(SetDesignSystemUnknownFailure()),
      ),
      seed: () => const DesignSystemState(
        isLoaded: true,
        designSystem: DesignSystem.xmas,
        isRestartRequired: true,
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const DesignSystemClickEvent(DesignSystem.holi)),
      expect: () => const [
        DesignSystemState(
          isLoaded: true,
          designSystem: DesignSystem.xmas,
          isRestartRequired: true,
          failure: SetDesignSystemUnknownFailure(),
        ),
      ],
    );

    blocTest<DesignSystemBloc, DesignSystemState>(
      'should propagate the reset failure and keep the selection when clearing fails',
      setUp: () => resetDesignSystemUseCase.stubCall(
        const Left(ResetDesignSystemUnknownFailure()),
      ),
      seed: () => const DesignSystemState(
        isLoaded: true,
        designSystem: DesignSystem.holi,
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const DesignSystemResetClickEvent()),
      expect: () => const [
        DesignSystemState(
          isLoaded: true,
          designSystem: DesignSystem.holi,
          failure: ResetDesignSystemUnknownFailure(),
        ),
      ],
    );
  });
}
