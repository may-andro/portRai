import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';

import '../../../../../mock/feature/design_system/domain/repository/mock_design_system_repository.dart';

void main() {
  group('SetDesignSystemUseCase', () {
    test(
      'should save the design system when the repository succeeds',
      () async {
        final repository = MockDesignSystemRepository()
          ..stubSetDesignSystem(DesignSystem.holi);

        final setDesignSystemEither = await SetDesignSystemUseCase(repository)(
          DesignSystem.holi,
        );

        expect(setDesignSystemEither.isRight, isTrue);
        verify(() => repository.setDesignSystem(DesignSystem.holi)).called(1);
      },
    );

    test(
      'should preserve the cause in a set failure when saving throws',
      () async {
        final error = StateError('Cannot write design system');
        final repository = MockDesignSystemRepository()
          ..stubSetDesignSystemThrows(DesignSystem.holi, error);

        final setDesignSystemEither = await SetDesignSystemUseCase(repository)(
          DesignSystem.holi,
        );

        expect(setDesignSystemEither.isLeft, isTrue);
        expect(
          setDesignSystemEither.left,
          isA<SetDesignSystemUnknownFailure>(),
        );
        expect(setDesignSystemEither.left.cause, same(error));
      },
    );
  });
}
