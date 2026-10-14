import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';

import '../../../../../mock/feature/design_system/domain/repository/mock_design_system_repository.dart';

void main() {
  group('ResetDesignSystemUseCase', () {
    test(
      'should clear the design system when the repository succeeds',
      () async {
        final repository = MockDesignSystemRepository()
          ..stubClearDesignSystem();

        final resetDesignSystemEither = await ResetDesignSystemUseCase(
          repository,
        )();

        expect(resetDesignSystemEither.isRight, isTrue);
        verify(repository.clearDesignSystem).called(1);
      },
    );

    test(
      'should preserve the cause in a reset failure when clearing throws',
      () async {
        final error = StateError('Cannot clear design system');
        final repository = MockDesignSystemRepository()
          ..stubClearDesignSystemThrows(error);

        final resetDesignSystemEither = await ResetDesignSystemUseCase(
          repository,
        )();

        expect(resetDesignSystemEither.isLeft, isTrue);
        expect(
          resetDesignSystemEither.left,
          isA<ResetDesignSystemUnknownFailure>(),
        );
        expect(resetDesignSystemEither.left.cause, same(error));
      },
    );
  });
}
