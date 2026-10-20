import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/onboarding/domain/feature_flag/_feature_flag.dart';
import 'package:portrai/src/feature/onboarding/domain/use_case/get_guest_user_use_case.dart';
import 'package:use_case/use_case.dart';

sealed class ShouldShowOnboardingFailure extends BasicFailure {
  const ShouldShowOnboardingFailure({super.cause});
}

@Localizable('errorGeneric')
class ShouldShowOnboardingUnknownFailure extends ShouldShowOnboardingFailure {
  const ShouldShowOnboardingUnknownFailure({super.cause});
}

/// Onboarding is shown when its flag is on and the user has no saved user.
@register
class ShouldShowOnboardingUseCase
    extends BaseNoParamUseCase<bool, ShouldShowOnboardingFailure> {
  ShouldShowOnboardingUseCase(
    this._isFeatureEnabledUseCase,
    this._getGuestUserUseCase,
  );

  final IsFeatureEnabledUseCase _isFeatureEnabledUseCase;
  final GetGuestUserUseCase _getGuestUserUseCase;

  @protected
  @override
  FutureOr<Either<ShouldShowOnboardingFailure, bool>> execute() async {
    final isEnabledEither = await _isFeatureEnabledUseCase(
      OnboardingFeatureFlags.roleOnboarding,
    );
    if (isEnabledEither.isLeft) {
      return Left(
        ShouldShowOnboardingUnknownFailure(cause: isEnabledEither.left),
      );
    }
    if (!isEnabledEither.right) return const Right(false);

    final userEither = await _getGuestUserUseCase();
    if (userEither.isLeft) {
      return Left(ShouldShowOnboardingUnknownFailure(cause: userEither.left));
    }
    return Right(userEither.right == null);
  }

  @protected
  @override
  ShouldShowOnboardingFailure mapErrorToFailure(Object e, StackTrace st) =>
      ShouldShowOnboardingUnknownFailure(cause: e);
}
