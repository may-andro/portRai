import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/design_system/domain/use_case/mock_reset_design_system_use_case.dart';
import '../../../../../mock/feature/design_system/domain/use_case/mock_select_design_system_use_case.dart';
import '../../../../../mock/feature/design_system/domain/use_case/mock_set_design_system_use_case.dart';

void main() {
  group('ApplyDesignSystemUseCase', () {
    late MockSelectDesignSystemUseCase selectDesignSystemUseCase;
    late MockSetDesignSystemUseCase setDesignSystemUseCase;
    late MockResetDesignSystemUseCase resetDesignSystemUseCase;

    setUp(() {
      selectDesignSystemUseCase = MockSelectDesignSystemUseCase()
        ..stubCall(DesignSystem.halloween);
      setDesignSystemUseCase = MockSetDesignSystemUseCase()
        ..registerFallbacks()
        ..stubCall(const Right(null));
      resetDesignSystemUseCase = MockResetDesignSystemUseCase()
        ..stubCall(const Right(null));
    });

    ApplyDesignSystemUseCase buildUseCase() => ApplyDesignSystemUseCase(
      selectDesignSystemUseCase,
      setDesignSystemUseCase,
      resetDesignSystemUseCase,
    );

    test(
      'should save the design system when it is not the one of this month',
      () async {
        final applyDesignSystemEither = await buildUseCase()(DesignSystem.holi);

        expect(applyDesignSystemEither.isRight, isTrue);
        verify(() => setDesignSystemUseCase(DesignSystem.holi)).called(1);
        verifyNever(() => resetDesignSystemUseCase());
      },
    );

    test('should clear the saved choice when the design system is the one of '
        'this month', () async {
      final applyDesignSystemEither = await buildUseCase()(
        DesignSystem.halloween,
      );

      expect(applyDesignSystemEither.isRight, isTrue);
      verify(() => resetDesignSystemUseCase()).called(1);
      verifyNever(() => setDesignSystemUseCase(any()));
    });

    test('should return a failure when saving fails', () async {
      const setFailure = SetDesignSystemUnknownFailure();
      setDesignSystemUseCase.stubCall(const Left(setFailure));

      final applyDesignSystemEither = await buildUseCase()(DesignSystem.holi);

      expect(
        applyDesignSystemEither.left,
        isA<ApplyDesignSystemUnknownFailure>().having(
          (failure) => failure.cause,
          'cause',
          setFailure,
        ),
      );
    });

    test('should return a failure when clearing fails', () async {
      const resetFailure = ResetDesignSystemUnknownFailure();
      resetDesignSystemUseCase.stubCall(const Left(resetFailure));

      final applyDesignSystemEither = await buildUseCase()(
        DesignSystem.halloween,
      );

      expect(
        applyDesignSystemEither.left,
        isA<ApplyDesignSystemUnknownFailure>().having(
          (failure) => failure.cause,
          'cause',
          resetFailure,
        ),
      );
    });
  });
}
