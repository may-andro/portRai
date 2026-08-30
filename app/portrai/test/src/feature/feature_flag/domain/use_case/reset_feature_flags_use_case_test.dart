import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';

import '../../../../../mock/feature/feature_flag/domain/repository/mock_app_feature_flag_repository.dart';

void main() {
  group('ResetFeatureFlagsUseCase', () {
    late MockAppFeatureFlagRepository repository;
    late ResetFeatureFlagsUseCase useCase;

    setUp(() {
      repository = MockAppFeatureFlagRepository();
      useCase = ResetFeatureFlagsUseCase(repository);
    });

    test('should return success when the repository reset completes', () async {
      repository.stubReset();

      final result = await useCase();

      expect(result.isRight, isTrue);
      verify(() => repository.reset()).called(1);
    });

    test(
      'should return FeatureFlagsResetFailure when the reset throws',
      () async {
        repository.stubResetThrows(Exception('boom'));

        final result = await useCase();

        expect(result.isLeft, isTrue);
        expect(result.left, isA<FeatureFlagsResetFailure>());
      },
    );
  });
}
