import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/call_booking/domain/_domain.dart';
import 'package:portrai/src/feature/call_booking/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/call_booking/presentation/screen/book_call/bloc/_bloc.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/utility/legal_urls.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/call_booking/domain/use_case/mock_get_call_slots_use_case.dart';
import '../../../../../../../mock/feature/call_booking/domain/use_case/mock_request_call_use_case.dart';
import '../../../../../../../mock/feature/call_booking/presentation/screen/book_call/tracking/mock_book_call_tracking_delegate.dart';
import '../../../../../../../mock/feature/call_booking/test_data/call_booking_test_data.dart';
import '../../../../../../../mock/feature/external_app_handler/domain/use_case/fake_open_external_url_param.dart';
import '../../../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';

void main() {
  final callSlots = createCallSlotsEntity();
  final days = callSlots.slotsByLocalDay.keys.toList();
  final firstSlot = callSlotStarts.first.toLocal();

  setUpAll(() {
    registerFallbackValue(FakeOpenExternalUrlParam());
    registerFallbackValue(
      RequestCallParam(
        slotStart: callSlotStarts.first,
        name: '',
        email: '',
        topic: '',
        message: '',
        hasAcceptedPrivacyPolicy: false,
      ),
    );
  });

  const sendEvent = SendCallRequestClickEvent(
    label: 'send_call_request_button',
    name: 'Visitor Name',
    email: 'visitor@example.com',
    topic: 'App Development',
    message: '',
    hasAcceptedPrivacyPolicy: true,
  );

  group('BookCallBloc', () {
    late MockGetCallSlotsUseCase getCallSlots;
    late MockRequestCallUseCase requestCall;
    late MockOpenExternalUrlUseCase openUrl;
    late MockBookCallTrackingDelegate tracking;

    BookCallBloc buildBloc() =>
        BookCallBloc(getCallSlots, requestCall, openUrl, tracking);

    final choosing = BookCallState(
      status: BookCallStatus.choosing,
      callSlots: callSlots,
      selectedDay: days.first,
    );
    final chosen = choosing.copyWith(selectedSlot: firstSlot);

    setUp(() {
      getCallSlots = MockGetCallSlotsUseCase();
      requestCall = MockRequestCallUseCase();
      openUrl = MockOpenExternalUrlUseCase();
      tracking = MockBookCallTrackingDelegate();
    });

    blocTest<BookCallBloc, BookCallState>(
      'should show the first day with free times once the slots load',
      setUp: () => getCallSlots.stubCall(Right(callSlots)),
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadCallSlotsEvent()),
      expect: () => [const BookCallState(), choosing],
    );

    blocTest<BookCallBloc, BookCallState>(
      'should show the load failure and load again on retry',
      setUp: () =>
          getCallSlots.stubCall(const Left(GetCallSlotsNetworkFailure())),
      build: buildBloc,
      act: (bloc) => bloc.add(const CallSlotsRetryClickEvent()),
      expect: () => [
        const BookCallState(),
        const BookCallState(
          status: BookCallStatus.loadFailed,
          loadFailure: GetCallSlotsNetworkFailure(),
        ),
      ],
    );

    blocTest<BookCallBloc, BookCallState>(
      'should pick another day and clear the chosen time',
      build: buildBloc,
      seed: () => chosen,
      act: (bloc) =>
          bloc.add(CallDayClickEvent(label: 'call_day_chip', day: days.last)),
      expect: () => [choosing.copyWith(selectedDay: days.last)],
      verify: (_) => verify(
        () => tracking.trackDayClick(
          label: 'call_day_chip',
          day: days.last.toIso8601String().substring(0, 10),
        ),
      ).called(1),
    );

    blocTest<BookCallBloc, BookCallState>(
      'should choose a time and track it in UTC',
      build: buildBloc,
      seed: () => choosing,
      act: (bloc) => bloc.add(
        CallSlotClickEvent(label: 'call_slot_chip', slot: firstSlot),
      ),
      expect: () => [chosen],
      verify: (_) => verify(
        () => tracking.trackSlotClick(
          label: 'call_slot_chip',
          slotStart: '2026-11-03T14:00:00.000Z',
        ),
      ).called(1),
    );

    blocTest<BookCallBloc, BookCallState>(
      'should ignore picks while a request is being sent',
      build: buildBloc,
      seed: () => chosen.copyWith(status: BookCallStatus.sending),
      act: (bloc) => bloc.add(
        CallSlotClickEvent(label: 'call_slot_chip', slot: firstSlot),
      ),
      expect: () => const <BookCallState>[],
    );

    blocTest<BookCallBloc, BookCallState>(
      'should send the request for the chosen time and show it as sent',
      setUp: () => requestCall.stubCall(const Right('request-1')),
      build: buildBloc,
      seed: () => chosen,
      act: (bloc) => bloc.add(sendEvent),
      expect: () => [
        chosen.copyWith(status: BookCallStatus.sending),
        chosen.copyWith(status: BookCallStatus.sent),
      ],
      verify: (_) {
        final param =
            verify(() => requestCall(captureAny())).captured.single
                as RequestCallParam;
        expect(param.slotStart, firstSlot);
        expect(param.email, 'visitor@example.com');
        expect(param.hasAcceptedPrivacyPolicy, isTrue);
        verify(
          () => tracking.trackSendClick('send_call_request_button'),
        ).called(1);
        verify(
          () => tracking.trackViewEvent('call_request_sent_view'),
        ).called(1);
      },
    );

    blocTest<BookCallBloc, BookCallState>(
      'should not send before a time is chosen',
      build: buildBloc,
      seed: () => choosing,
      act: (bloc) => bloc.add(sendEvent),
      expect: () => const <BookCallState>[],
      verify: (_) => verifyNever(() => requestCall(any())),
    );

    blocTest<BookCallBloc, BookCallState>(
      'should keep the form and report why the request was not sent',
      setUp: () =>
          requestCall.stubCall(const Left(RequestCallConsentMissingFailure())),
      build: buildBloc,
      seed: () => chosen,
      act: (bloc) => bloc.add(sendEvent),
      expect: () => [
        chosen.copyWith(status: BookCallStatus.sending),
        chosen.copyWith(sendFailure: const RequestCallConsentMissingFailure()),
      ],
    );

    blocTest<BookCallBloc, BookCallState>(
      'should load the free times again when the chosen one was taken',
      setUp: () {
        requestCall.stubCall(const Left(RequestCallSlotUnavailableFailure()));
        getCallSlots.stubCall(
          Right(createCallSlotsEntity(slots: callSlotStarts.sublist(1))),
        );
      },
      build: buildBloc,
      seed: () => chosen,
      act: (bloc) => bloc.add(sendEvent),
      expect: () => [
        chosen.copyWith(status: BookCallStatus.sending),
        BookCallState(
          status: BookCallStatus.choosing,
          callSlots: createCallSlotsEntity(slots: callSlotStarts.sublist(1)),
          selectedDay: createCallSlotsEntity(
            slots: callSlotStarts.sublist(1),
          ).slotsByLocalDay.keys.first,
          sendFailure: const RequestCallSlotUnavailableFailure(),
        ),
      ],
    );

    blocTest<BookCallBloc, BookCallState>(
      'should open and track the privacy policy',
      setUp: () => openUrl.stubCall(const Right(true)),
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
