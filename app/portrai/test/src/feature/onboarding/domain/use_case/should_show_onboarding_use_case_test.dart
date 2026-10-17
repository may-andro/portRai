import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/onboarding/domain/_domain.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';
import '../../../../../mock/feature/onboarding/domain/use_case/mock_get_user_use_case.dart';

void main() {
  group('ShouldShowOnboardingUseCase', () {
    late MockIsFeatureEnabledUseCase isFeatureEnabledUseCase;
    late MockGetUserUseCase getUserUseCase;

    setUp(() {
      isFeatureEnabledUseCase = MockIsFeatureEnabledUseCase();
      getUserUseCase = MockGetUserUseCase();
    });

    ShouldShowOnboardingUseCase buildUseCase() =>
        ShouldShowOnboardingUseCase(isFeatureEnabledUseCase, getUserUseCase);

    void stubFlag(Either<IsFeatureEnabledFailure, bool> result) {
      isFeatureEnabledUseCase.stubCall(
        definition: OnboardingFeatureFlags.roleOnboarding,
        result: result,
      );
    }

    test('should return false when the flag is disabled', () async {
      stubFlag(const Right(false));
      getUserUseCase.stubCall(null);

      final shouldShowEither = await buildUseCase()();

      expect(shouldShowEither.right, isFalse);
    });

    test(
      'should return true when the flag is on and no user is saved',
      () async {
        stubFlag(const Right(true));
        getUserUseCase.stubCall(null);

        final shouldShowEither = await buildUseCase()();

        expect(shouldShowEither.right, isTrue);
      },
    );

    test(
      'should return false when the flag is on and a user is saved',
      () async {
        stubFlag(const Right(true));
        getUserUseCase.stubCall(const UserEntity(role: UserRole.other));

        final shouldShowEither = await buildUseCase()();

        expect(shouldShowEither.right, isFalse);
      },
    );

    test('should return a failure when the flag cannot be read', () async {
      stubFlag(const Left(FeatureFlagUnknownFailure()));
      getUserUseCase.stubCall(null);

      final shouldShowEither = await buildUseCase()();

      expect(shouldShowEither.left, isA<ShouldShowOnboardingUnknownFailure>());
    });
  });
}
