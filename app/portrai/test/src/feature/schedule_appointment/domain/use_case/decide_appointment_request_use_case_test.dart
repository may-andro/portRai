import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/auth.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/auth/domain/use_case/mock_get_signed_in_user_use_case.dart';
import '../../../../../mock/feature/schedule_appointment/domain/repository/mock_appointment_request_repository.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(AppointmentDecision.accept);
  });

  group('DecideAppointmentRequestUseCase', () {
    late MockGetSignedInUserUseCase getSignedInUserUseCase;
    late MockAppointmentRequestRepository appointmentRequestRepository;

    const signedInUser = AuthUserEntity(id: 'owner-uid', email: null);
    const param = DecideAppointmentRequestParam(
      requestId: 'request-1',
      decision: AppointmentDecision.decline,
    );

    setUp(() {
      getSignedInUserUseCase = MockGetSignedInUserUseCase()
        ..stubCall(const Right(signedInUser));
      appointmentRequestRepository = MockAppointmentRequestRepository()
        ..stubDecideAppointmentRequest();
    });

    DecideAppointmentRequestUseCase buildUseCase() =>
        DecideAppointmentRequestUseCase(
          getSignedInUserUseCase,
          appointmentRequestRepository,
        );

    test('should save the answer for the signed-in owner', () async {
      final decideEither = await buildUseCase()(param);

      expect(decideEither.isRight, isTrue);
      verify(
        () => appointmentRequestRepository.decideAppointmentRequest(
          userId: 'owner-uid',
          id: 'request-1',
          decision: AppointmentDecision.decline,
        ),
      ).called(1);
    });

    test('should return a signed-out failure without saving when nobody is '
        'signed in', () async {
      getSignedInUserUseCase.stubCall(const Right(null));

      final decideEither = await buildUseCase()(param);

      expect(
        decideEither.left,
        isA<DecideAppointmentRequestSignedOutFailure>(),
      );
      verifyNever(
        () => appointmentRequestRepository.decideAppointmentRequest(
          userId: any(named: 'userId'),
          id: any(named: 'id'),
          decision: any(named: 'decision'),
        ),
      );
    });

    test('should return an unknown failure with the auth failure as its cause '
        'when the user cannot be read', () async {
      const authFailure = GetSignedInUserUnknownFailure();
      getSignedInUserUseCase.stubCall(const Left(authFailure));

      final decideEither = await buildUseCase()(param);

      expect(
        decideEither.left,
        isA<DecideAppointmentRequestUnknownFailure>().having(
          (failure) => failure.cause,
          'cause',
          authFailure,
        ),
      );
    });

    for (final (exception, failureMatcher) in [
      (
        const AppointmentRequestNotFoundException(),
        isA<DecideAppointmentRequestNotFoundFailure>(),
      ),
      (
        const AppointmentRequestPermissionDeniedException(),
        isA<DecideAppointmentRequestPermissionDeniedFailure>(),
      ),
      (
        const ScheduleAppointmentNetworkException(),
        isA<DecideAppointmentRequestNetworkFailure>(),
      ),
      (
        const ScheduleAppointmentUnknownException(),
        isA<DecideAppointmentRequestUnknownFailure>(),
      ),
    ]) {
      test('should map ${exception.runtimeType} to its failure', () async {
        appointmentRequestRepository.stubDecideAppointmentRequestThrows(
          exception,
        );

        final decideEither = await buildUseCase()(param);

        expect(decideEither.left, failureMatcher);
      });
    }
  });
}
