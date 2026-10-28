import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/auth.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/auth/domain/use_case/mock_get_signed_in_user_use_case.dart';
import '../../../../../mock/feature/schedule_appointment/domain/entity/received_appointment_request_entity_fixture.dart';
import '../../../../../mock/feature/schedule_appointment/domain/repository/mock_appointment_request_repository.dart';

void main() {
  group('GetAppointmentRequestsUseCase', () {
    late MockGetSignedInUserUseCase getSignedInUserUseCase;
    late MockAppointmentRequestRepository appointmentRequestRepository;

    const signedInUser = AuthUserEntity(id: 'owner-uid', email: null);

    setUp(() {
      getSignedInUserUseCase = MockGetSignedInUserUseCase()
        ..stubCall(const Right(signedInUser));
      appointmentRequestRepository = MockAppointmentRequestRepository();
    });

    GetAppointmentRequestsUseCase buildUseCase() =>
        GetAppointmentRequestsUseCase(
          getSignedInUserUseCase,
          appointmentRequestRepository,
        );

    test('should return the requests earliest slot first when a user is '
        'signed in', () async {
      appointmentRequestRepository.stubGetAppointmentRequests([
        receivedAppointmentRequestEntityFixture(
          id: 'later',
          slotStart: DateTime.utc(2026, 11, 5, 14),
        ),
        receivedAppointmentRequestEntityFixture(
          id: 'earlier',
          slotStart: DateTime.utc(2026, 11, 3, 14),
        ),
      ]);

      final requestsEither = await buildUseCase()();

      expect(requestsEither.right.map((request) => request.id), [
        'earlier',
        'later',
      ]);
      verify(
        () => appointmentRequestRepository.getAppointmentRequests('owner-uid'),
      ).called(1);
    });

    test('should return a signed-out failure without reading when nobody is '
        'signed in', () async {
      getSignedInUserUseCase.stubCall(const Right(null));

      final requestsEither = await buildUseCase()();

      expect(
        requestsEither.left,
        isA<GetAppointmentRequestsSignedOutFailure>(),
      );
      verifyNever(
        () => appointmentRequestRepository.getAppointmentRequests(any()),
      );
    });

    test('should return an unknown failure with the auth failure as its cause '
        'when the user cannot be read', () async {
      const authFailure = GetSignedInUserUnknownFailure();
      getSignedInUserUseCase.stubCall(const Left(authFailure));

      final requestsEither = await buildUseCase()();

      expect(
        requestsEither.left,
        isA<GetAppointmentRequestsUnknownFailure>().having(
          (failure) => failure.cause,
          'cause',
          authFailure,
        ),
      );
    });

    for (final (exception, failureMatcher) in [
      (
        const AppointmentRequestPermissionDeniedException(),
        isA<GetAppointmentRequestsPermissionDeniedFailure>(),
      ),
      (
        const ScheduleAppointmentNetworkException(),
        isA<GetAppointmentRequestsNetworkFailure>(),
      ),
      (
        const ScheduleAppointmentUnknownException(),
        isA<GetAppointmentRequestsUnknownFailure>(),
      ),
    ]) {
      test('should map ${exception.runtimeType} to its failure', () async {
        appointmentRequestRepository.stubGetAppointmentRequestsThrows(
          exception,
        );

        final requestsEither = await buildUseCase()();

        expect(requestsEither.left, failureMatcher);
      });
    }
  });
}
