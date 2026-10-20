import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/onboarding/presentation/screen/onboarding/bloc/_bloc.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/onboarding/presentation/screen/onboarding/tracking/mock_onboarding_tracking_delegate.dart';
import '../../../../../../../mock/feature/user/domain/use_case/mock_save_guest_user_use_case.dart';

void main() {
  group('OnboardingBloc', () {
    late MockSaveGuestUserUseCase saveGuestUserUseCase;
    late MockOnboardingTrackingDelegate trackingDelegate;

    setUp(() {
      saveGuestUserUseCase = MockSaveGuestUserUseCase();
      trackingDelegate = MockOnboardingTrackingDelegate();
    });

    OnboardingBloc buildBloc() =>
        OnboardingBloc(saveGuestUserUseCase, trackingDelegate);

    blocTest<OnboardingBloc, OnboardingState>(
      'should track the screen view when started',
      build: buildBloc,
      act: (bloc) => bloc.add(const OnboardingStartedEvent()),
      expect: () => const <OnboardingState>[],
      verify: (_) => verify(() => trackingDelegate.trackScreenView()).called(1),
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'should save the role and complete when a role is selected',
      setUp: () => saveGuestUserUseCase.stubCall(
        const GuestUserEntity(role: UserRole.developer),
        const Right(null),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const RoleSelectedClickEvent(UserRole.developer)),
      expect: () => const [
        OnboardingState(selectedRole: UserRole.developer),
        OnboardingState(selectedRole: UserRole.developer, isCompleted: true),
      ],
      verify: (_) {
        verify(
          () => trackingDelegate.trackRoleSelection('developer'),
        ).called(1);
        verify(
          () => saveGuestUserUseCase(
            const GuestUserEntity(role: UserRole.developer),
          ),
        ).called(1);
      },
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'should emit a failure when saving the role fails',
      setUp: () => saveGuestUserUseCase.stubCall(
        const GuestUserEntity(role: UserRole.recruiter),
        const Left(SaveGuestUserUnknownFailure()),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const RoleSelectedClickEvent(UserRole.recruiter)),
      expect: () => const [
        OnboardingState(selectedRole: UserRole.recruiter),
        OnboardingState(failure: SaveGuestUserUnknownFailure()),
      ],
    );
  });
}
