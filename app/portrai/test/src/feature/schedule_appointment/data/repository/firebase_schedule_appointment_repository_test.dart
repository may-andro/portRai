import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/data/_data.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';

import '../../../../../mock/feature/schedule_appointment/test_data/schedule_appointment_test_data.dart';
import '../../../../../mock/utility/mock_fb_function_controller.dart';
import '../../../../../mock/utility/mock_function_invalid_argument_exception.dart';

void main() {
  group('FirebaseScheduleAppointmentRepository', () {
    late MockFbFunctionController functionController;
    late FirebaseScheduleAppointmentRepository repository;

    setUp(() {
      functionController = MockFbFunctionController();
      repository = FirebaseScheduleAppointmentRepository(
        functionController,
        const AppointmentSlotsMapper(),
        AppointmentRequestMapper(AppLocale('en')),
      );
    });

    test(
      'should load the slots without sign-in from a map with object keys',
      () async {
        functionController.stubCallFunction(
          'getCallSlots',
          Map<Object?, Object?>.from(createAppointmentSlotsJson()),
        );

        final appointmentSlots = await repository.getAppointmentSlots();

        expect(appointmentSlots, createAppointmentSlotsEntity());
        verify(
          () => functionController.callFunction(
            'getCallSlots',
            requiresSignIn: false,
          ),
        ).called(1);
      },
    );

    test(
      'should send the request with a limited-use token and return its ID',
      () async {
        functionController.stubCallFunction('requestCall', {
          'requestId': 'request-1',
        });

        final requestId = await repository.requestAppointment(
          createAppointmentRequestEntity(),
        );

        expect(requestId, 'request-1');
        final parameters =
            verify(
                  () => functionController.callFunction(
                    'requestCall',
                    parameters: captureAny(named: 'parameters'),
                    requiresSignIn: false,
                    limitedUseAppCheckToken: true,
                  ),
                ).captured.single
                as Map<String, dynamic>;
        expect(parameters['slotStart'], '2026-11-03T14:00:00.000Z');
        expect(parameters['email'], 'visitor@example.com');
      },
    );

    test(
      'should report an unknown error when the response has no ID',
      () async {
        functionController.stubCallFunction('requestCall', <String, Object?>{});

        await expectLater(
          repository.requestAppointment(createAppointmentRequestEntity()),
          throwsA(isA<ScheduleAppointmentUnknownException>()),
        );
      },
    );

    test(
      'should report an unknown error when the slots do not parse',
      () async {
        functionController.stubCallFunction('getCallSlots', {'slots': 'none'});

        await expectLater(
          repository.getAppointmentSlots(),
          throwsA(isA<ScheduleAppointmentUnknownException>()),
        );
      },
    );

    for (final (reason, exceptionMatcher) in [
      ('not_set_up', isA<ScheduleAppointmentNotSetUpException>()),
      ('slot_taken', isA<AppointmentSlotUnavailableException>()),
      ('slot_not_offered', isA<AppointmentSlotUnavailableException>()),
      ('too_many_open_requests', isA<AppointmentRequestLimitException>()),
      ('daily_limit', isA<AppointmentRequestLimitException>()),
      ('invalid', isA<AppointmentRequestInvalidException>()),
      ('something_new', isA<ScheduleAppointmentUnknownException>()),
    ]) {
      test('should map the $reason refusal to its exception', () async {
        functionController.stubCallFunctionThrows(
          'requestCall',
          MockFunctionInvalidArgumentException()
            ..stubDetails({'reason': reason}),
        );

        await expectLater(
          repository.requestAppointment(createAppointmentRequestEntity()),
          throwsA(exceptionMatcher),
        );
      });
    }

    test(
      'should report a network error when the function cannot be reached',
      () async {
        functionController.stubCallFunctionThrows(
          'getCallSlots',
          FunctionNetworkException(
            'getCallSlots',
            Exception('offline'),
            StackTrace.empty,
          ),
        );

        await expectLater(
          repository.getAppointmentSlots(),
          throwsA(isA<ScheduleAppointmentNetworkException>()),
        );
      },
    );
  });
}
