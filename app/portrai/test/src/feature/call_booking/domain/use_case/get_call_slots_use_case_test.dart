import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/call_booking/domain/_domain.dart';

import '../../../../../mock/feature/call_booking/domain/repository/mock_call_booking_repository.dart';
import '../../../../../mock/feature/call_booking/test_data/call_booking_test_data.dart';

void main() {
  group('GetCallSlotsUseCase', () {
    late MockCallBookingRepository repository;
    late GetCallSlotsUseCase useCase;

    setUp(() {
      repository = MockCallBookingRepository();
      useCase = GetCallSlotsUseCase(repository);
    });

    test(
      'should return the free slots when the repository loads them',
      () async {
        final callSlots = createCallSlotsEntity();
        repository.stubGetCallSlots(callSlots);

        final callSlotsEither = await useCase();

        expect(callSlotsEither.right, callSlots);
      },
    );

    for (final (exception, failureMatcher) in [
      (
        const CallBookingNotSetUpException(),
        isA<GetCallSlotsNotSetUpFailure>(),
      ),
      (const CallBookingNetworkException(), isA<GetCallSlotsNetworkFailure>()),
      (const CallBookingUnknownException(), isA<GetCallSlotsUnknownFailure>()),
    ]) {
      test(
        'should map ${exception.runtimeType} to its failure when loading fails',
        () async {
          repository.stubGetCallSlotsThrows(exception);

          final callSlotsEither = await useCase();

          expect(callSlotsEither.left, failureMatcher);
        },
      );
    }
  });
}
