import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/call_booking/domain/_domain.dart';

import '../../../../../mock/feature/call_booking/domain/repository/mock_call_booking_repository.dart';
import '../../../../../mock/feature/call_booking/test_data/call_booking_test_data.dart';

void main() {
  setUpAll(() => registerFallbackValue(createCallRequestEntity()));

  RequestCallParam param({
    String name = ' Visitor Name ',
    String email = ' visitor@example.com ',
    String topic = ' App Development ',
    String message = ' Looking for help. ',
    bool hasAcceptedPrivacyPolicy = true,
  }) => RequestCallParam(
    slotStart: callSlotStarts.first,
    name: name,
    email: email,
    topic: topic,
    message: message,
    hasAcceptedPrivacyPolicy: hasAcceptedPrivacyPolicy,
  );

  group('RequestCallUseCase', () {
    late MockCallBookingRepository repository;
    late RequestCallUseCase useCase;

    setUp(() {
      repository = MockCallBookingRepository();
      useCase = RequestCallUseCase(repository);
    });

    test('should send the trimmed request and return its ID', () async {
      repository.stubRequestCall('request-1');

      final requestCallEither = await useCase(param());

      expect(requestCallEither.right, 'request-1');
      verify(() => repository.requestCall(createCallRequestEntity())).called(1);
    });

    for (final (description, invalidParam, failureMatcher) in [
      (
        'a missing name',
        param(name: '  '),
        isA<RequestCallMissingDetailsFailure>(),
      ),
      (
        'a missing topic',
        param(topic: ''),
        isA<RequestCallMissingDetailsFailure>(),
      ),
      (
        'a missing message',
        param(message: '  '),
        isA<RequestCallMissingDetailsFailure>(),
      ),
      (
        'an invalid email',
        param(email: 'visitor@example'),
        isA<RequestCallInvalidEmailFailure>(),
      ),
      (
        'no consent',
        param(hasAcceptedPrivacyPolicy: false),
        isA<RequestCallConsentMissingFailure>(),
      ),
    ]) {
      test('should refuse $description without sending', () async {
        final requestCallEither = await useCase(invalidParam);

        expect(requestCallEither.left, failureMatcher);
        verifyNever(() => repository.requestCall(any()));
      });
    }

    for (final (exception, failureMatcher) in [
      (
        const CallSlotUnavailableException(),
        isA<RequestCallSlotUnavailableFailure>(),
      ),
      (const CallRequestLimitException(), isA<RequestCallLimitFailure>()),
      (const CallRequestInvalidException(), isA<RequestCallInvalidFailure>()),
      (const CallBookingNotSetUpException(), isA<RequestCallNotSetUpFailure>()),
      (const CallBookingNetworkException(), isA<RequestCallNetworkFailure>()),
      (const CallBookingUnknownException(), isA<RequestCallUnknownFailure>()),
    ]) {
      test(
        'should map ${exception.runtimeType} to its failure when sending fails',
        () async {
          repository.stubRequestCallThrows(exception);

          final requestCallEither = await useCase(param());

          expect(requestCallEither.left, failureMatcher);
        },
      );
    }

    test('should not print the visitor details when the param is logged', () {
      expect(param().toString(), isNot(contains('visitor@example.com')));
      expect(param().toString(), isNot(contains('Visitor Name')));
    });
  });
}
