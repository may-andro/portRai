import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/schedule_appointment/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/app_config/domain/use_case/mock_get_privacy_policy_url_use_case.dart';
import '../../../../../../../mock/feature/external_app_handler/domain/use_case/fake_open_external_url_param.dart';
import '../../../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
import '../../../../../../../mock/feature/schedule_appointment/domain/use_case/mock_get_appointment_slots_use_case.dart';
import '../../../../../../../mock/feature/schedule_appointment/domain/use_case/mock_request_appointment_use_case.dart';
import '../../../../../../../mock/feature/schedule_appointment/presentation/screen/schedule_appointment/tracking/mock_schedule_appointment_tracking_delegate.dart';
import '../../../../../../../mock/feature/schedule_appointment/test_data/schedule_appointment_test_data.dart';

void main() {
  final privacyPolicyUrl = Uri.parse(
    'https://legal.example.com/privacy-policy',
  );
  final appointmentSlots = createAppointmentSlotsEntity();
  final days = appointmentSlots.slotsByLocalDay.keys.toList();
  final firstSlot = appointmentSlotStarts.first.toLocal();

  setUpAll(() {
    registerFallbackValue(FakeOpenExternalUrlParam());
    registerFallbackValue(
      RequestAppointmentParam(
        slotStart: appointmentSlotStarts.first,
        name: '',
        email: '',
        topic: '',
        message: '',
        hasAcceptedPrivacyPolicy: false,
      ),
    );
  });

  const sendEvent = SendAppointmentRequestClickEvent(
    label: 'send_appointment_request_button',
    name: 'Visitor Name',
    email: 'visitor@example.com',
    topic: 'App Development',
    message: '',
    hasAcceptedPrivacyPolicy: true,
  );

  group('ScheduleAppointmentBloc', () {
    late MockGetAppointmentSlotsUseCase getAppointmentSlots;
    late MockRequestAppointmentUseCase requestAppointment;
    late MockOpenExternalUrlUseCase openUrl;
    late MockGetPrivacyPolicyUrlUseCase getPrivacyPolicyUrl;
    late MockScheduleAppointmentTrackingDelegate tracking;

    ScheduleAppointmentBloc buildBloc() => ScheduleAppointmentBloc(
      getAppointmentSlots,
      requestAppointment,
      openUrl,
      getPrivacyPolicyUrl,
      tracking,
    );

    final choosing = ScheduleAppointmentState(
      status: ScheduleAppointmentStatus.choosing,
      appointmentSlots: appointmentSlots,
      selectedDay: days.first,
    );
    final chosen = choosing.copyWith(selectedSlot: firstSlot);

    setUp(() {
      getAppointmentSlots = MockGetAppointmentSlotsUseCase();
      requestAppointment = MockRequestAppointmentUseCase();
      openUrl = MockOpenExternalUrlUseCase();
      getPrivacyPolicyUrl = MockGetPrivacyPolicyUrlUseCase();
      tracking = MockScheduleAppointmentTrackingDelegate();
    });

    blocTest<ScheduleAppointmentBloc, ScheduleAppointmentState>(
      'should show the first day with free times once the slots load',
      setUp: () => getAppointmentSlots.stubCall(Right(appointmentSlots)),
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadAppointmentSlotsEvent()),
      expect: () => [const ScheduleAppointmentState(), choosing],
    );

    blocTest<ScheduleAppointmentBloc, ScheduleAppointmentState>(
      'should show the load failure and load again on retry',
      setUp: () => getAppointmentSlots.stubCall(
        const Left(GetAppointmentSlotsNetworkFailure()),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const AppointmentSlotsRetryClickEvent()),
      expect: () => [
        const ScheduleAppointmentState(),
        const ScheduleAppointmentState(
          status: ScheduleAppointmentStatus.loadFailed,
          loadFailure: GetAppointmentSlotsNetworkFailure(),
        ),
      ],
    );

    blocTest<ScheduleAppointmentBloc, ScheduleAppointmentState>(
      'should pick another day and clear the chosen time',
      build: buildBloc,
      seed: () => chosen,
      act: (bloc) => bloc.add(
        AppointmentDayClickEvent(label: 'appointment_day_chip', day: days.last),
      ),
      expect: () => [choosing.copyWith(selectedDay: days.last)],
      verify: (_) => verify(
        () => tracking.trackDayClick(
          label: 'appointment_day_chip',
          day: days.last.toIso8601String().substring(0, 10),
        ),
      ).called(1),
    );

    blocTest<ScheduleAppointmentBloc, ScheduleAppointmentState>(
      'should choose a time and track it in UTC',
      build: buildBloc,
      seed: () => choosing,
      act: (bloc) => bloc.add(
        AppointmentSlotClickEvent(
          label: 'appointment_slot_chip',
          slot: firstSlot,
        ),
      ),
      expect: () => [chosen],
      verify: (_) => verify(
        () => tracking.trackSlotClick(
          label: 'appointment_slot_chip',
          slotStart: '2026-11-03T14:00:00.000Z',
        ),
      ).called(1),
    );

    blocTest<ScheduleAppointmentBloc, ScheduleAppointmentState>(
      'should ignore picks while a request is being sent',
      build: buildBloc,
      seed: () => chosen.copyWith(status: ScheduleAppointmentStatus.sending),
      act: (bloc) => bloc.add(
        AppointmentSlotClickEvent(
          label: 'appointment_slot_chip',
          slot: firstSlot,
        ),
      ),
      expect: () => const <ScheduleAppointmentState>[],
    );

    blocTest<ScheduleAppointmentBloc, ScheduleAppointmentState>(
      'should send the request for the chosen time and show it as sent',
      setUp: () => requestAppointment.stubCall(const Right('request-1')),
      build: buildBloc,
      seed: () => chosen,
      act: (bloc) => bloc.add(sendEvent),
      expect: () => [
        chosen.copyWith(status: ScheduleAppointmentStatus.sending),
        chosen.copyWith(status: ScheduleAppointmentStatus.sent),
      ],
      verify: (_) {
        final param =
            verify(() => requestAppointment(captureAny())).captured.single
                as RequestAppointmentParam;
        expect(param.slotStart, firstSlot);
        expect(param.email, 'visitor@example.com');
        expect(param.hasAcceptedPrivacyPolicy, isTrue);
        verify(
          () => tracking.trackSendClick('send_appointment_request_button'),
        ).called(1);
        verify(
          () => tracking.trackViewEvent('appointment_request_sent_view'),
        ).called(1);
      },
    );

    blocTest<ScheduleAppointmentBloc, ScheduleAppointmentState>(
      'should not send before a time is chosen',
      build: buildBloc,
      seed: () => choosing,
      act: (bloc) => bloc.add(sendEvent),
      expect: () => const <ScheduleAppointmentState>[],
      verify: (_) => verifyNever(() => requestAppointment(any())),
    );

    blocTest<ScheduleAppointmentBloc, ScheduleAppointmentState>(
      'should keep the form and report why the request was not sent',
      setUp: () => requestAppointment.stubCall(
        const Left(RequestAppointmentConsentMissingFailure()),
      ),
      build: buildBloc,
      seed: () => chosen,
      act: (bloc) => bloc.add(sendEvent),
      expect: () => [
        chosen.copyWith(status: ScheduleAppointmentStatus.sending),
        chosen.copyWith(
          sendFailure: const RequestAppointmentConsentMissingFailure(),
        ),
      ],
    );

    blocTest<ScheduleAppointmentBloc, ScheduleAppointmentState>(
      'should load the free times again when the chosen one was taken',
      setUp: () {
        requestAppointment.stubCall(
          const Left(RequestAppointmentSlotUnavailableFailure()),
        );
        getAppointmentSlots.stubCall(
          Right(
            createAppointmentSlotsEntity(
              slots: appointmentSlotStarts.sublist(1),
            ),
          ),
        );
      },
      build: buildBloc,
      seed: () => chosen,
      act: (bloc) => bloc.add(sendEvent),
      expect: () => [
        chosen.copyWith(status: ScheduleAppointmentStatus.sending),
        ScheduleAppointmentState(
          status: ScheduleAppointmentStatus.choosing,
          appointmentSlots: createAppointmentSlotsEntity(
            slots: appointmentSlotStarts.sublist(1),
          ),
          selectedDay: createAppointmentSlotsEntity(
            slots: appointmentSlotStarts.sublist(1),
          ).slotsByLocalDay.keys.first,
          sendFailure: const RequestAppointmentSlotUnavailableFailure(),
        ),
      ],
    );

    blocTest<ScheduleAppointmentBloc, ScheduleAppointmentState>(
      'should open and track the privacy policy',
      setUp: () {
        openUrl.stubCall(const Right(true));
        getPrivacyPolicyUrl.stubCall(Right(privacyPolicyUrl));
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const PrivacyPolicyClickEvent('privacy_policy_link')),
      verify: (_) {
        verify(
          () => openUrl(
            any(
              that: isA<OpenExternalUrlParam>().having(
                (param) => param.uri,
                'uri',
                privacyPolicyUrl,
              ),
            ),
          ),
        ).called(1);
        verify(
          () => tracking.trackPrivacyPolicyClick('privacy_policy_link'),
        ).called(1);
      },
    );

    test(
      'should not print the visitor details when the send event is logged',
      () {
        expect(sendEvent.toString(), isNot(contains('visitor@example.com')));
      },
    );
  });
}
