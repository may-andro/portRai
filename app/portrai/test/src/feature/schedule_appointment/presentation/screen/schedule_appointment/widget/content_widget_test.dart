import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/schedule_appointment/bloc/_bloc.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/schedule_appointment/widget/_widget.dart';

import '../../../../../../../mock/feature/schedule_appointment/presentation/screen/schedule_appointment/bloc/mock_schedule_appointment_bloc.dart';
import '../../../../../../../mock/feature/schedule_appointment/test_data/schedule_appointment_test_data.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  final appointmentSlots = createAppointmentSlotsEntity();
  final days = appointmentSlots.slotsByLocalDay.keys.toList();
  final firstSlot = appointmentSlotStarts.first.toLocal();
  final choosing = ScheduleAppointmentState(
    status: ScheduleAppointmentStatus.choosing,
    appointmentSlots: appointmentSlots,
    selectedDay: days.first,
  );

  Finder tilesWithKeyPrefix(String prefix) => find.byWidgetPredicate(
    (widget) => switch (widget.key) {
      ValueKey<String>(:final value) => value.startsWith(prefix),
      _ => false,
    },
  );
  Future<void> pickDay(WidgetTester tester, DateTime day) async {
    final dropdown = find.byType(DropdownButtonFormField<DateTime>);
    final label = day.formattedAppointmentDayLong(tester.element(dropdown));
    // The header keeps animating, so the menu gets a fixed time to open.
    await tester.tap(dropdown);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text(label).last);
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<(MockScheduleAppointmentBloc, AppLocalizations)> pump(
    WidgetTester tester,
    ScheduleAppointmentState state, {
    String topic = '',
    Size size = const Size(390, 1800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final bloc = MockScheduleAppointmentBloc()..stubState(state);
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<ScheduleAppointmentBloc>.value(
          value: bloc,
          child: ContentWidget(topic: topic),
        ),
      ),
    );
    await tester.pump();
    return (
      bloc,
      AppLocalizations.of(tester.element(find.byType(ContentWidget))),
    );
  }

  group('ScheduleAppointment ContentWidget', () {
    testWidgets('should show loading while the free times load', (
      tester,
    ) async {
      await pump(tester, const ScheduleAppointmentState());

      expect(find.byType(DSLoadingWidget), findsOneWidget);
    });

    testWidgets('should show an error card with retry when loading fails', (
      tester,
    ) async {
      await pump(
        tester,
        const ScheduleAppointmentState(
          status: ScheduleAppointmentStatus.loadFailed,
          loadFailure: GetAppointmentSlotsNetworkFailure(),
        ),
      );

      expect(find.byType(DSErrorCardWidget), findsOneWidget);
    });

    testWidgets("should show a day dropdown and the selected day's times", (
      tester,
    ) async {
      final (_, localizations) = await pump(tester, choosing);

      expect(find.byType(DropdownButtonFormField<DateTime>), findsOneWidget);
      expect(
        find.text(
          days.first.formattedAppointmentDayLong(
            tester.element(find.byType(ContentWidget)),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.text(localizations.scheduleAppointmentFreeTimesTitle),
        findsOneWidget,
      );
      expect(
        tilesWithKeyPrefix('appointment_slot_'),
        findsNWidgets(appointmentSlots.slotsByLocalDay[days.first]!.length),
      );
    });

    testWidgets('should send the picked day and time to the bloc', (
      tester,
    ) async {
      final (bloc, _) = await pump(tester, choosing);
      final context = tester.element(find.byType(ContentWidget));

      await tester.tap(find.text(firstSlot.formattedAppointmentTime(context)));
      await pickDay(tester, days.last);

      verify(
        () => bloc.add(
          AppointmentDayClickEvent(
            label: 'appointment_day_dropdown',
            day: days.last,
          ),
        ),
      ).called(1);
      verify(
        () => bloc.add(
          AppointmentSlotClickEvent(
            label: 'appointment_slot_chip',
            slot: firstSlot,
          ),
        ),
      ).called(1);
    });

    testWidgets('should offer only the free days', (tester) async {
      await pump(tester, choosing);
      final dropdown = find.byType(DropdownButtonFormField<DateTime>);

      await tester.tap(dropdown);
      await tester.pump(const Duration(milliseconds: 500));

      final context = tester.element(find.byType(ContentWidget));
      // The menu lists each free day once; the field shows the picked one too.
      expect(
        find.byType(DropdownMenuItem<DateTime>),
        findsNWidgets(days.length + 1),
      );
      for (final day in days) {
        expect(
          find.text(day.formattedAppointmentDayLong(context)),
          findsWidgets,
        );
      }
    });

    testWidgets('should ask only for a name, email and message', (
      tester,
    ) async {
      await pump(tester, choosing);

      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('should send the details once a time is chosen', (
      tester,
    ) async {
      final (bloc, localizations) = await pump(
        tester,
        choosing.copyWith(selectedSlot: firstSlot),
        topic: 'App Development',
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Visitor Name');
      await tester.enterText(fields.at(1), 'visitor@example.com');
      await tester.enterText(fields.at(2), 'About an app');
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.ensureVisible(
        find.text(localizations.scheduleAppointmentSend),
      );
      await tester.tap(find.text(localizations.scheduleAppointmentSend));

      verify(
        () => bloc.add(
          const SendAppointmentRequestClickEvent(
            label: 'send_appointment_request_button',
            name: 'Visitor Name',
            email: 'visitor@example.com',
            topic: 'App Development',
            message: 'About an app',
            hasAcceptedPrivacyPolicy: true,
          ),
        ),
      ).called(1);
    });

    testWidgets('should send a general topic when opened without one', (
      tester,
    ) async {
      final (bloc, localizations) = await pump(
        tester,
        choosing.copyWith(selectedSlot: firstSlot),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Visitor Name');
      await tester.enterText(fields.at(1), 'visitor@example.com');
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.ensureVisible(
        find.text(localizations.scheduleAppointmentSend),
      );
      await tester.tap(find.text(localizations.scheduleAppointmentSend));

      verify(
        () => bloc.add(
          SendAppointmentRequestClickEvent(
            label: 'send_appointment_request_button',
            name: 'Visitor Name',
            email: 'visitor@example.com',
            topic: localizations.scheduleAppointmentDefaultTopic,
            message: '',
            hasAcceptedPrivacyPolicy: true,
          ),
        ),
      ).called(1);
    });

    testWidgets('should open the privacy policy from its link', (tester) async {
      final (bloc, localizations) = await pump(tester, choosing);

      await tester.tap(
        find.text(localizations.scheduleAppointmentPrivacyPolicyLink),
      );

      verify(
        () => bloc.add(const PrivacyPolicyClickEvent('privacy_policy_link')),
      ).called(1);
    });

    testWidgets('should say so when no time is free', (tester) async {
      final (_, localizations) = await pump(
        tester,
        ScheduleAppointmentState(
          status: ScheduleAppointmentStatus.choosing,
          appointmentSlots: createAppointmentSlotsEntity(slots: []),
        ),
      );

      expect(
        find.text(localizations.scheduleAppointmentNoSlots),
        findsOneWidget,
      );
      expect(find.byType(DropdownButtonFormField<DateTime>), findsNothing);
    });

    testWidgets('should confirm the request once it is sent', (tester) async {
      final (_, localizations) = await pump(
        tester,
        choosing.copyWith(status: ScheduleAppointmentStatus.sent),
      );

      expect(
        find.text(localizations.scheduleAppointmentSentTitle),
        findsOneWidget,
      );
      expect(
        find.text(localizations.scheduleAppointmentSentDone),
        findsOneWidget,
      );
      expect(find.byType(TextFormField), findsNothing);
    });

    testWidgets('should celebrate the sent request with confetti once', (
      tester,
    ) async {
      await pump(
        tester,
        choosing.copyWith(status: ScheduleAppointmentStatus.sent),
      );

      final confetti = find.byWidgetPredicate(
        (widget) =>
            widget is DSLottieIllustrationWidget &&
            widget.illustration == DSLottieIllustration.confetti,
      );
      expect(confetti, findsOneWidget);
      expect(
        tester.widget<DSLottieIllustrationWidget>(confetti).playback,
        DSLottiePlayback.once,
      );
    });

    testWidgets('should show the title to the right of the form on desktop', (
      tester,
    ) async {
      final (_, localizations) = await pump(
        tester,
        choosing,
        size: const Size(1440, 900),
      );
      final title = find.text(localizations.scheduleAppointmentHeroTitle);

      expect(title, findsOneWidget);
      expect(
        tester.getTopLeft(title).dx,
        greaterThan(
          tester
              .getTopRight(
                find.text(localizations.scheduleAppointmentNameLabel),
              )
              .dx,
        ),
      );
      // Lets the copy's entrance animation finish.
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('should keep the title in view while a short desktop window '
        'scrolls', (tester) async {
      final (_, localizations) = await pump(
        tester,
        choosing,
        size: const Size(1440, 640),
      );
      final title = find.text(localizations.scheduleAppointmentHeroTitle);
      final titleTop = tester.getTopLeft(title).dy;

      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(40);
      await tester.pump();

      expect(tester.getTopLeft(title).dy, moreOrLessEquals(titleTop));
      // Lets the copy's entrance animation finish.
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('should fit the whole form on a desktop screen', (
      tester,
    ) async {
      final (_, localizations) = await pump(
        tester,
        choosing,
        size: const Size(1440, 900),
      );

      expect(
        tester
            .getBottomLeft(find.text(localizations.scheduleAppointmentSend))
            .dy,
        lessThanOrEqualTo(900),
      );
      // Lets the copy's entrance animation finish.
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('should head the screen with its title', (tester) async {
      final (_, localizations) = await pump(tester, choosing);

      expect(
        find.text(localizations.scheduleAppointmentHeroTitle),
        findsOneWidget,
      );
    });
  });
}
