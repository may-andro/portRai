import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';

import '../../../../../mock/feature/schedule_appointment/domain/repository/mock_schedule_appointment_repository.dart';
import '../../../../../mock/feature/schedule_appointment/test_data/schedule_appointment_test_data.dart';

void main() {
  setUpAll(() => registerFallbackValue(createAppointmentRequestEntity()));

  RequestAppointmentParam param({
    String name = ' Visitor Name ',
    String email = ' visitor@example.com ',
    String topic = ' App Development ',
    String message = ' Looking for help. ',
    bool hasAcceptedPrivacyPolicy = true,
  }) => RequestAppointmentParam(
    slotStart: appointmentSlotStarts.first,
    name: name,
    email: email,
    topic: topic,
    message: message,
    hasAcceptedPrivacyPolicy: hasAcceptedPrivacyPolicy,
  );

  group('RequestAppointmentUseCase', () {
    late MockScheduleAppointmentRepository repository;
    late RequestAppointmentUseCase useCase;

    setUp(() {
      repository = MockScheduleAppointmentRepository();
      useCase = RequestAppointmentUseCase(repository);
    });

    test('should send the trimmed request and return its ID', () async {
      repository.stubRequestAppointment('request-1');

      final requestAppointmentEither = await useCase(param());

      expect(requestAppointmentEither.right, 'request-1');
      verify(
        () => repository.requestAppointment(createAppointmentRequestEntity()),
      ).called(1);
    });

    for (final (description, invalidParam, failureMatcher) in [
      (
        'a missing name',
        param(name: '  '),
        isA<RequestAppointmentMissingDetailsFailure>(),
      ),
      (
        'a missing topic',
        param(topic: ''),
        isA<RequestAppointmentMissingDetailsFailure>(),
      ),
      (
        'a missing message',
        param(message: '  '),
        isA<RequestAppointmentMissingDetailsFailure>(),
      ),
      (
        'an invalid email',
        param(email: 'visitor@example'),
        isA<RequestAppointmentInvalidEmailFailure>(),
      ),
      (
        'no consent',
        param(hasAcceptedPrivacyPolicy: false),
        isA<RequestAppointmentConsentMissingFailure>(),
      ),
    ]) {
      test('should refuse $description without sending', () async {
        final requestAppointmentEither = await useCase(invalidParam);

        expect(requestAppointmentEither.left, failureMatcher);
        verifyNever(() => repository.requestAppointment(any()));
      });
    }

    for (final (exception, failureMatcher) in [
      (
        const AppointmentSlotUnavailableException(),
        isA<RequestAppointmentSlotUnavailableFailure>(),
      ),
      (
        const AppointmentRequestLimitException(),
        isA<RequestAppointmentLimitFailure>(),
      ),
      (
        const AppointmentRequestInvalidException(),
        isA<RequestAppointmentInvalidFailure>(),
      ),
      (
        const ScheduleAppointmentNotSetUpException(),
        isA<RequestAppointmentNotSetUpFailure>(),
      ),
      (
        const ScheduleAppointmentNetworkException(),
        isA<RequestAppointmentNetworkFailure>(),
      ),
      (
        const ScheduleAppointmentUnknownException(),
        isA<RequestAppointmentUnknownFailure>(),
      ),
    ]) {
      test(
        'should map ${exception.runtimeType} to its failure when sending fails',
        () async {
          repository.stubRequestAppointmentThrows(exception);

          final requestAppointmentEither = await useCase(param());

          expect(requestAppointmentEither.left, failureMatcher);
        },
      );
    }

    test('should not print the visitor details when the param is logged', () {
      expect(param().toString(), isNot(contains('visitor@example.com')));
      expect(param().toString(), isNot(contains('Visitor Name')));
    });
  });
}
