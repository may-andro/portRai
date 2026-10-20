import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/auth/domain/use_case/fake_sign_in_param.dart';
import '../../../../../../../mock/feature/auth/domain/use_case/mock_sign_in_use_case.dart';
import '../../../../../../../mock/feature/auth/presentation/screen/sign_in/tracking/mock_sign_in_tracking_delegate.dart';

void main() {
  setUpAll(() => registerFallbackValue(FakeSignInParam()));

  group('SignInBloc', () {
    late MockSignInUseCase signInUseCase;
    late MockSignInTrackingDelegate trackingDelegate;

    setUp(() {
      signInUseCase = MockSignInUseCase();
      trackingDelegate = MockSignInTrackingDelegate();
    });

    SignInBloc buildBloc() => SignInBloc(signInUseCase, trackingDelegate);

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

    test('should hide the credentials when the click event is printed', () {
      expect(signInClickEvent.toString(), isNot(contains('owner@example.com')));
      expect(signInClickEvent.toString(), isNot(contains('secret')));
    });
  });
}
