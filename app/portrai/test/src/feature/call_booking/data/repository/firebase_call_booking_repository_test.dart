import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/call_booking/data/_data.dart';
import 'package:portrai/src/feature/call_booking/domain/_domain.dart';

import '../../../../../mock/feature/call_booking/test_data/call_booking_test_data.dart';
import '../../../../../mock/utility/mock_fb_function_controller.dart';
import '../../../../../mock/utility/mock_function_invalid_argument_exception.dart';

void main() {
  group('FirebaseCallBookingRepository', () {
    late MockFbFunctionController functionController;
    late FirebaseCallBookingRepository repository;

    setUp(() {
      functionController = MockFbFunctionController();
      repository = FirebaseCallBookingRepository(
        functionController,
        const CallSlotsMapper(),
        CallRequestMapper(AppLocale('en')),
      );
    });

    test(
      'should load the slots without sign-in from a map with object keys',
      () async {
        functionController.stubCallFunction(
          'getCallSlots',
          Map<Object?, Object?>.from(createCallSlotsJson()),
        );

        final callSlots = await repository.getCallSlots();

        expect(callSlots, createCallSlotsEntity());
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

        final requestId = await repository.requestCall(
          createCallRequestEntity(),
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
          repository.requestCall(createCallRequestEntity()),
          throwsA(isA<CallBookingUnknownException>()),
        );
      },
    );

    test(
      'should report an unknown error when the slots do not parse',
      () async {
        functionController.stubCallFunction('getCallSlots', {'slots': 'none'});

        await expectLater(
          repository.getCallSlots(),
          throwsA(isA<CallBookingUnknownException>()),
        );
      },
    );

    for (final (reason, exceptionMatcher) in [
      ('not_set_up', isA<CallBookingNotSetUpException>()),
      ('slot_taken', isA<CallSlotUnavailableException>()),
      ('slot_not_offered', isA<CallSlotUnavailableException>()),
      ('too_many_open_requests', isA<CallRequestLimitException>()),
      ('daily_limit', isA<CallRequestLimitException>()),
      ('invalid', isA<CallRequestInvalidException>()),
      ('something_new', isA<CallBookingUnknownException>()),
    ]) {
      test('should map the $reason refusal to its exception', () async {
        functionController.stubCallFunctionThrows(
          'requestCall',
          MockFunctionInvalidArgumentException()
            ..stubDetails({'reason': reason}),
        );

        await expectLater(
          repository.requestCall(createCallRequestEntity()),
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
          repository.getCallSlots(),
          throwsA(isA<CallBookingNetworkException>()),
        );
      },
    );
  });
}
