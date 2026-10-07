import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/_bloc.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/widget/content_widget.dart';

import '../../../../../../../mock/feature/developer_mode/presentation/screen/developer_menu/bloc/mock_developer_menu_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('DeveloperMenu ContentWidget', () {
    testWidgets(
      'should render a loading indicator and track its impression when loading',
      (tester) async {
        final bloc = MockDeveloperMenuBloc()
          ..stubState(const DeveloperMenuLoadingState());

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<DeveloperMenuBloc>.value(
              value: bloc,
              child: const ContentWidget(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DSLoadingWidget), findsOneWidget);
        verify(() => bloc.add(ViewStateVisibleEvent.loading())).called(1);
      },
    );

    testWidgets(
      'should render an error card and track its impression when loading fails',
      (tester) async {
        final bloc = MockDeveloperMenuBloc()
          ..stubState(const DeveloperMenuErrorState('boom'));

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<DeveloperMenuBloc>.value(
              value: bloc,
              child: const ContentWidget(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DSErrorCardWidget), findsOneWidget);
        verify(() => bloc.add(ViewStateVisibleEvent.error())).called(1);
      },
    );

    testWidgets(
      'should render localized actions and dispatch events when the action tiles are tapped',
      (tester) async {
        final bloc = MockDeveloperMenuBloc()
          ..stubState(const DeveloperMenuLoadedState());

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<DeveloperMenuBloc>.value(
              value: bloc,
              child: const ContentWidget(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Controls & Tools'), findsOneWidget);
        expect(find.text('Cache Playground'), findsOneWidget);
        expect(find.text('Feature Flags'), findsOneWidget);
        expect(find.text('Error Simulation'), findsOneWidget);

        await tester.tap(find.text('Force Fatal Crash'));
        await tester.pump();
        await tester.tap(find.text('Force Non-Fatal Crash'));
        await tester.pump();
        await tester.tap(find.text('Force Blacklist Error'));
        await tester.pump();

        verify(() => bloc.add(ViewStateVisibleEvent.success())).called(1);
        verify(() => bloc.add(const ForceFatalCrashEvent())).called(1);
        verify(() => bloc.add(const ForceNonFatalCrashEvent())).called(1);
        verify(() => bloc.add(const ForceBlacklistErrorEvent())).called(1);
      },
    );
  });
}
