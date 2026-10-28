import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';

import '../../../../../mock/feature/schedule_appointment/domain/repository/mock_schedule_appointment_repository.dart';
import '../../../../../mock/feature/schedule_appointment/test_data/schedule_appointment_test_data.dart';

void main() {
  group('GetAppointmentSlotsUseCase', () {
    late MockScheduleAppointmentRepository repository;
    late GetAppointmentSlotsUseCase useCase;

    setUp(() {
      repository = MockScheduleAppointmentRepository();
      useCase = GetAppointmentSlotsUseCase(repository);
    });

    test(
      'should return the free slots when the repository loads them',
      () async {
        final appointmentSlots = createAppointmentSlotsEntity();
        repository.stubGetAppointmentSlots(appointmentSlots);

        final appointmentSlotsEither = await useCase();

        expect(appointmentSlotsEither.right, appointmentSlots);
      },
    );

    for (final (exception, failureMatcher) in [
      (
        const ScheduleAppointmentNotSetUpException(),
        isA<GetAppointmentSlotsNotSetUpFailure>(),
      ),
      (
        const ScheduleAppointmentNetworkException(),
        isA<GetAppointmentSlotsNetworkFailure>(),
      ),
      (
        const ScheduleAppointmentUnknownException(),
        isA<GetAppointmentSlotsUnknownFailure>(),
      ),
    ]) {
      test(
        'should map ${exception.runtimeType} to its failure when loading fails',
        () async {
          repository.stubGetAppointmentSlotsThrows(exception);

          final appointmentSlotsEither = await useCase();

          expect(appointmentSlotsEither.left, failureMatcher);
        },
      );
    }
  });
}
