import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/call_booking/presentation/widget/book_call_entry/bloc/_bloc.dart';

import '../../../../../../../mock/feature/call_booking/domain/use_case/mock_is_call_booking_available_use_case.dart';
import '../../../../../../../mock/feature/call_booking/presentation/widget/book_call_entry/tracking/mock_book_call_entry_tracking_delegate.dart';

void main() {
  group('BookCallEntryBloc', () {
    late MockIsCallBookingAvailableUseCase isAvailableUseCase;
    late MockBookCallEntryTrackingDelegate tracking;

    BookCallEntryBloc buildBloc() =>
        BookCallEntryBloc(isAvailableUseCase, tracking);

    setUp(() {
      isAvailableUseCase = MockIsCallBookingAvailableUseCase();
      tracking = MockBookCallEntryTrackingDelegate();
    });

    test('should start unavailable so the entry never flashes in', () {
      expect(buildBloc().state, const BookCallEntryState());
    });

    blocTest<BookCallEntryBloc, BookCallEntryState>(
      'should become available when booking is on',
      setUp: () => isAvailableUseCase.stubCall(true),
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadBookCallEntryEvent()),
      expect: () => [const BookCallEntryState(isAvailable: true)],
    );

    blocTest<BookCallEntryBloc, BookCallEntryState>(
      'should stay unavailable when booking is off',
      setUp: () => isAvailableUseCase.stubCall(false),
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadBookCallEntryEvent()),
      expect: () => [const BookCallEntryState()],
    );

    blocTest<BookCallEntryBloc, BookCallEntryState>(
      'should track the tap with its label and topic',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const BookCallClickEvent(
          label: 'service_book_call_button',
          topic: 'App Development',
        ),
      ),
      expect: () => const <BookCallEntryState>[],
      verify: (_) => verify(
        () => tracking.trackBookCallClick(
          label: 'service_book_call_button',
          topic: 'App Development',
        ),
      ).called(1),
    );
  });
}
