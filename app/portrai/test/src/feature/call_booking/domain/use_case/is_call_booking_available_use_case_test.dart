import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/call_booking/domain/_domain.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';

void main() {
  group('IsCallBookingAvailableUseCase', () {
    late MockIsFeatureEnabledUseCase isFeatureEnabledUseCase;
    late IsCallBookingAvailableUseCase useCase;

    setUp(() {
      isFeatureEnabledUseCase = MockIsFeatureEnabledUseCase();
      useCase = IsCallBookingAvailableUseCase(isFeatureEnabledUseCase);
    });

    for (final isEnabled in [true, false]) {
      test('should return $isEnabled when the flag is $isEnabled', () async {
        isFeatureEnabledUseCase.stubCall(
          definition: CallBookingFeatureFlags.callBooking,
          result: Right(isEnabled),
        );

        final isAvailableEither = await useCase();

        expect(isAvailableEither.right, isEnabled);
      });
    }

    test('should return false when the flag cannot be read', () async {
      isFeatureEnabledUseCase.stubCall(
        definition: CallBookingFeatureFlags.callBooking,
        result: const Left(FeatureFlagUnknownFailure()),
      );

      final isAvailableEither = await useCase();

      expect(isAvailableEither.right, isFalse);
    });
  });
}
