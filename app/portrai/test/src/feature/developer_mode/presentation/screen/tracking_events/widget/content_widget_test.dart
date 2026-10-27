import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/developer_mode/domain/_domain.dart';
import 'package:portrai/src/feature/developer_mode/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/tracking_events/bloc/_bloc.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/tracking_events/widget/_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

import '../../../../../../../mock/feature/developer_mode/domain/entity/tracking_event_entity_fixture.dart';
import '../../../../../../../mock/feature/developer_mode/presentation/screen/tracking_events/bloc/mock_tracking_events_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  const phoneSize = Size(400, 2400);
  const tabletSize = Size(800, 2400);
  const desktopSize = Size(1440, 2400);

  final clickEvent = trackingEventEntityFixture(id: '2');
  final screenViewEvent = trackingEventEntityFixture(
    name: 'screen_view',
    area: 'portfolio',
    actionType: null,
    parameters: {'event': 'screen_view', 'area': 'portfolio'},
  );

  Future<MockTrackingEventsBloc> pumpContent(
    WidgetTester tester,
    TrackingEventsState state, {
    Size size = desktopSize,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final bloc = MockTrackingEventsBloc()..stubState(state);
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: ScreenFooterProviderWidget(
          footer: const SizedBox.shrink(),
          child: BlocProvider<TrackingEventsBloc>.value(
            value: bloc,
            child: const ContentWidget(),
          ),
        ),
      ),
    );
    await tester.pump();
    return bloc;
  }

  TrackingEventsLoadedState loadedState({
    List<TrackingEventEntity>? trackingEvents,
    String searchQuery = '',
    Set<String> nameFilters = const {},
    String? selectedTrackingEventId,
  }) => TrackingEventsLoadedState(
    trackingEvents ?? [clickEvent, screenViewEvent],
    searchQuery: searchQuery,
    nameFilters: nameFilters,
    selectedTrackingEventId: selectedTrackingEventId,
  );

  Finder payloadOf(TrackingEventEntity trackingEvent) =>
      find.text(trackingEvent.payload);

  for (final (layout, size) in [
    ('phone', phoneSize),
    ('desktop', desktopSize),
  ]) {
    testWidgets('should list every event with its time, area and parameters '
        'when loaded on a $layout', (tester) async {
      await pumpContent(tester, loadedState(), size: size);

      expect(find.text('Tracking Viewer'), findsWidgets);
      expect(find.text('2 events'), findsOneWidget);
      expect(find.text('14:05:09.042'), findsNWidgets(2));
      expect(find.text('experience'), findsOneWidget);
      expect(find.text('label: header_tab'), findsOneWidget);
    });
  }

  testWidgets('should show the time since the previous event when events '
      'follow each other on the timeline', (tester) async {
    final firstSentAt = DateTime(2026, 10, 27, 15, 25, 29, 77);
    await pumpContent(
      tester,
      loadedState(
        trackingEvents: [
          trackingEventEntityFixture(id: '0', sentAt: firstSentAt),
          trackingEventEntityFixture(
            sentAt: firstSentAt.add(const Duration(milliseconds: 340)),
          ),
          trackingEventEntityFixture(
            id: '2',
            sentAt: firstSentAt.add(const Duration(milliseconds: 7740)),
          ),
        ],
      ),
    );

    expect(find.text('+340 ms'), findsOneWidget);
    expect(find.text('+7.4 s'), findsOneWidget);
  });

  testWidgets('should title a screen view with the screen it opens when '
      'shown on the timeline', (tester) async {
    await pumpContent(tester, loadedState());

    final screenViewTitle = find.text('portfolio');
    final screenViewName = find.text('screen_view');
    expect(screenViewTitle, findsWidgets);
    expect(
      tester.getTopLeft(screenViewTitle.last).dy,
      lessThan(tester.getTopLeft(screenViewName.last).dy),
    );
  });

  testWidgets('should show the time above the event name when shown on a '
      'phone', (tester) async {
    await pumpContent(tester, loadedState(), size: phoneSize);

    final timeRect = tester.getRect(find.text('14:05:09.042').first);
    final nameRect = tester.getRect(find.text('click').last);
    expect(timeRect.bottom, lessThanOrEqualTo(nameRect.top));
  });

  for (final (layout, size) in [
    ('tablet', tabletSize),
    ('desktop', desktopSize),
  ]) {
    testWidgets('should show the time in a column before the event card when '
        'shown on a $layout', (tester) async {
      await pumpContent(tester, loadedState(), size: size);

      final timeRight = tester.getTopRight(find.text('14:05:09.042').first).dx;
      final nameLeft = tester.getTopLeft(find.text('click').last).dx;
      expect(timeRight, lessThan(nameLeft));
    });
  }

  testWidgets('should select the event when its card is tapped', (
    tester,
  ) async {
    final bloc = await pumpContent(tester, loadedState(), size: phoneSize);

    await tester.tap(find.text('label: header_tab'));

    verify(() => bloc.add(const TrackingEventClickEvent('2'))).called(1);
  });

  for (final (layout, size) in [('phone', phoneSize), ('tablet', tabletSize)]) {
    testWidgets('should expand only the selected event to show its payload '
        'when shown on a $layout', (tester) async {
      await pumpContent(
        tester,
        loadedState(selectedTrackingEventId: '2'),
        size: size,
      );

      expect(payloadOf(clickEvent), findsOneWidget);
      expect(payloadOf(screenViewEvent), findsNothing);
      expect(find.text('Select an event to see what was sent'), findsNothing);
      expect(find.byIcon(Icons.expand_less), findsOneWidget);
    });
  }

  testWidgets('should show the selected event payload in the side panel when '
      'shown on a desktop', (tester) async {
    await pumpContent(tester, loadedState(selectedTrackingEventId: '2'));

    final payloadLeft = tester.getTopLeft(payloadOf(clickEvent)).dx;
    final cardRight = tester.getTopRight(find.text('label: header_tab')).dx;
    expect(payloadLeft, greaterThan(cardRight));
    expect(find.byIcon(Icons.expand_less), findsNothing);
  });

  testWidgets('should ask to select an event in the side panel when none is '
      'selected on a desktop', (tester) async {
    await pumpContent(tester, loadedState());

    expect(find.text('Select an event to see what was sent'), findsOneWidget);
    expect(find.text('Payload'), findsNothing);
  });

  testWidgets('should copy the payload when copy is tapped', (tester) async {
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          copiedText = (methodCall.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpContent(tester, loadedState(selectedTrackingEventId: '2'));

    await tester.tap(find.text('Copy'));
    await tester.pump();

    expect(copiedText, clickEvent.payload);
    expect(find.text('Payload copied'), findsOneWidget);
  });

  testWidgets('should scroll the name chips sideways when shown on a phone', (
    tester,
  ) async {
    await pumpContent(tester, loadedState(), size: phoneSize);

    expect(
      find.ancestor(
        of: find.byType(FilterChip).first,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.horizontal,
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('should wrap the name chips when shown on a desktop', (
    tester,
  ) async {
    await pumpContent(tester, loadedState());

    expect(
      find.ancestor(
        of: find.byType(FilterChip).first,
        matching: find.byType(Wrap),
      ),
      findsOneWidget,
    );
  });

  testWidgets('should filter by the name when its chip is tapped', (
    tester,
  ) async {
    final bloc = await pumpContent(tester, loadedState());

    await tester.tap(find.widgetWithText(FilterChip, 'screen_view'));

    verify(
      () => bloc.add(const TrackingEventsNameFilterClickEvent('screen_view')),
    ).called(1);
  });

  testWidgets('should search when text is typed in the search field', (
    tester,
  ) async {
    final bloc = await pumpContent(tester, loadedState());

    await tester.enterText(find.byType(TextField), 'header');

    verify(
      () => bloc.add(const TrackingEventsSearchChangedEvent('header')),
    ).called(1);
  });

  testWidgets('should show the count and clear the filters when the list is '
      'narrowed', (tester) async {
    final bloc = await pumpContent(tester, loadedState(nameFilters: {'click'}));

    expect(find.text('Showing 1 of 2'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));

    verify(
      () => bloc.add(const TrackingEventsClearFiltersClickEvent()),
    ).called(1);
  });

  testWidgets('should show the no results message when nothing matches the '
      'search', (tester) async {
    await pumpContent(tester, loadedState(searchQuery: 'missing'));

    expect(find.text('No matching events'), findsOneWidget);
  });

  testWidgets('should show the empty message when no event was sent', (
    tester,
  ) async {
    await pumpContent(tester, loadedState(trackingEvents: const []));

    expect(find.text('No events yet'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('should show the not kept error and retry when the events are '
      'not kept', (tester) async {
    final bloc = await pumpContent(
      tester,
      const TrackingEventsErrorState(TrackingEventsNotKeptFailure()),
    );

    expect(
      find.text("This build doesn't keep the events it sends"),
      findsOneWidget,
    );
    await tester.tap(find.text('Retry'));

    verify(() => bloc.add(const TrackingEventsRefreshClickEvent())).called(1);
  });
}
