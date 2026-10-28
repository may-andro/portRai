import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/schedule_appointment_entry/bloc/_bloc.dart';

import '../../../../../../../mock/feature/schedule_appointment/domain/use_case/mock_is_schedule_appointment_available_use_case.dart';
import '../../../../../../../mock/feature/schedule_appointment/presentation/widget/schedule_appointment_entry/tracking/mock_schedule_appointment_entry_tracking_delegate.dart';

void main() {
  group('ScheduleAppointmentEntryBloc', () {
    late MockIsScheduleAppointmentAvailableUseCase isAvailableUseCase;
    late MockScheduleAppointmentEntryTrackingDelegate tracking;

    ScheduleAppointmentEntryBloc buildBloc() =>
        ScheduleAppointmentEntryBloc(isAvailableUseCase, tracking);

    setUp(() {
      isAvailableUseCase = MockIsScheduleAppointmentAvailableUseCase();
      tracking = MockScheduleAppointmentEntryTrackingDelegate();
    });

    test('should start unavailable so the entry never flashes in', () {
      expect(buildBloc().state, const ScheduleAppointmentEntryState());
    });

    blocTest<ScheduleAppointmentEntryBloc, ScheduleAppointmentEntryState>(
      'should become available when scheduling is on',
      setUp: () => isAvailableUseCase.stubCall(true),
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadScheduleAppointmentEntryEvent()),
      expect: () => [const ScheduleAppointmentEntryState(isAvailable: true)],
    );

    blocTest<ScheduleAppointmentEntryBloc, ScheduleAppointmentEntryState>(
      'should stay unavailable when scheduling is off',
      setUp: () => isAvailableUseCase.stubCall(false),
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadScheduleAppointmentEntryEvent()),
      expect: () => [const ScheduleAppointmentEntryState()],
    );

    blocTest<ScheduleAppointmentEntryBloc, ScheduleAppointmentEntryState>(
      'should track the tap with its label and topic',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ScheduleAppointmentClickEvent(
          label: 'service_schedule_appointment_button',
          topic: 'App Development',
        ),
      ),
      expect: () => const <ScheduleAppointmentEntryState>[],
      verify: (_) => verify(
        () => tracking.trackScheduleAppointmentClick(
          label: 'service_schedule_appointment_button',
          topic: 'App Development',
        ),
      ).called(1),
    );
  });
}
