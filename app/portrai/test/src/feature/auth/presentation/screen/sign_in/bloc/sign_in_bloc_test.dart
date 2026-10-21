import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/auth/domain/use_case/fake_sign_in_param.dart';
import '../../../../../../../mock/feature/auth/domain/use_case/mock_sign_in_use_case.dart';
import '../../../../../../../mock/feature/auth/presentation/screen/sign_in/tracking/mock_sign_in_tracking_delegate.dart';
import '../../../../../../../mock/feature/profile/domain/use_case/mock_get_profile_use_case.dart';
import '../../../../../../../mock/feature/profile/test_data/profile_test_data.dart';

void main() {
  setUpAll(() => registerFallbackValue(FakeSignInParam()));

  group('SignInBloc', () {
    late MockSignInUseCase signInUseCase;
    late MockSignInTrackingDelegate trackingDelegate;
    late MockGetProfileUseCase getProfileUseCase;

    setUp(() {
      signInUseCase = MockSignInUseCase();
      trackingDelegate = MockSignInTrackingDelegate();
      getProfileUseCase = MockGetProfileUseCase()
        ..stubCall(const Left(ProfileNetworkFailure()));
    });

    SignInBloc buildBloc() =>
        SignInBloc(signInUseCase, getProfileUseCase, trackingDelegate);

    const signInClickEvent = SignInClickEvent(
      email: 'owner@example.com',
      password: 'secret',
    );

    blocTest<SignInBloc, SignInState>(
      'should track the screen view when started',
      build: buildBloc,
      act: (bloc) => bloc.add(const SignInStartedEvent()),
      expect: () => const <SignInState>[],
      verify: (_) => verify(() => trackingDelegate.trackScreenView()).called(1),
    );

    blocTest<SignInBloc, SignInState>(
      'should sign in with the entered credentials when sign in is clicked',
      setUp: () => signInUseCase.stubCall(const Right(null)),
      build: buildBloc,
      act: (bloc) => bloc.add(signInClickEvent),
      expect: () => const [
        SignInState(isSigningIn: true),
        SignInState(isSignedIn: true),
      ],
      verify: (_) {
        verify(() => trackingDelegate.trackSignInClick()).called(1);
        final signInParam =
            verify(() => signInUseCase(captureAny())).captured.single
                as SignInParam;
        expect(signInParam.email, 'owner@example.com');
        expect(signInParam.password, 'secret');
      },
    );

    blocTest<SignInBloc, SignInState>(
      'should emit the failure when signing in fails',
      setUp: () =>
          signInUseCase.stubCall(const Left(SignInInvalidCredentialsFailure())),
      build: buildBloc,
      act: (bloc) => bloc.add(signInClickEvent),
      expect: () => const [
        SignInState(isSigningIn: true),
        SignInState(failure: SignInInvalidCredentialsFailure()),
      ],
    );

    blocTest<SignInBloc, SignInState>(
      'should ignore the click when already signed in',
      build: buildBloc,
      seed: () => const SignInState(isSignedIn: true),
      act: (bloc) => bloc.add(signInClickEvent),
      expect: () => const <SignInState>[],
      verify: (_) => verifyNever(() => signInUseCase(any())),
    );

    final profile = createProfileEntity();
    blocTest<SignInBloc, SignInState>(
      'should add the profile for the footer when started',
      setUp: () => getProfileUseCase.stubCall(Right(profile)),
      build: buildBloc,
      act: (bloc) => bloc.add(const SignInStartedEvent()),
      expect: () => [SignInState(profile: profile)],
    );

    blocTest<SignInBloc, SignInState>(
      'should keep the profile when signing in fails',
      setUp: () =>
          signInUseCase.stubCall(const Left(SignInInvalidCredentialsFailure())),
      build: buildBloc,
      seed: () => SignInState(profile: profile),
      act: (bloc) => bloc.add(signInClickEvent),
      expect: () => [
        SignInState(isSigningIn: true, profile: profile),
        SignInState(
          failure: const SignInInvalidCredentialsFailure(),
          profile: profile,
        ),
      ],
    );

    test('should hide the credentials when the click event is printed', () {
      expect(signInClickEvent.toString(), isNot(contains('owner@example.com')));
      expect(signInClickEvent.toString(), isNot(contains('secret')));
    });
  });
}
