import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';
import 'package:portrai/src/feature/design_system/presentation/bloc/design_system_bloc.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/_bloc.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/widget/content_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/design_system/domain/use_case/mock_get_design_system_use_case.dart';
import '../../../../../../../mock/feature/design_system/domain/use_case/mock_reset_design_system_use_case.dart';
import '../../../../../../../mock/feature/design_system/domain/use_case/mock_set_design_system_use_case.dart';
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
        verify(
          () => bloc.add(const ViewStateVisibleEvent('loading_content_view')),
        ).called(1);
      },
    );

    testWidgets(
      'should render an error card and track its impression when loading fails',
      (tester) async {
        final bloc = MockDeveloperMenuBloc()
          ..stubState(const DeveloperMenuErrorState(UnknownFailure()));

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
        expect(
          find.text('Something went wrong. Please try again'),
          findsOneWidget,
        );
        expect(find.text('Retry'), findsNothing);
        verify(
          () => bloc.add(const ViewStateVisibleEvent('error_content_view')),
        ).called(1);
      },
    );

    testWidgets(
      'should render localized actions and dispatch events when the action tiles are tapped',
      (tester) async {
        final bloc = MockDeveloperMenuBloc()
          ..stubState(const DeveloperMenuLoadedState());
        appServiceLocator.registerFactory<DesignSystemBloc>(
          () => DesignSystemBloc(
            MockGetDesignSystemUseCase()..stubCall(null),
            MockSetDesignSystemUseCase(),
            MockResetDesignSystemUseCase(),
          ),
        );
        addTearDown(appServiceLocator.reset);

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
        expect(find.byType(DesignSystemSelectorWidget), findsOneWidget);

        await tester.ensureVisible(find.text('Force Fatal Crash'));
        await tester.pump();
        await tester.tap(find.text('Force Fatal Crash'));
        await tester.pump();
        await tester.ensureVisible(find.text('Force Non-Fatal Crash'));
        await tester.pump();
        await tester.tap(find.text('Force Non-Fatal Crash'));
        await tester.pump();
        await tester.ensureVisible(find.text('Force Blacklist Error'));
        await tester.pump();
        await tester.tap(find.text('Force Blacklist Error'));
        await tester.pump();

        verify(
          () => bloc.add(const ViewStateVisibleEvent('loaded_content_view')),
        ).called(1);
        verify(() => bloc.add(const ForceFatalCrashEvent())).called(1);
        verify(() => bloc.add(const ForceNonFatalCrashEvent())).called(1);
        verify(() => bloc.add(const ForceBlacklistErrorEvent())).called(1);
      },
    );

    testWidgets(
      'should render the menu inside the shared scroll view followed by the footer when loaded',
      (tester) async {
        final bloc = MockDeveloperMenuBloc()
          ..stubState(const DeveloperMenuLoadedState());
        appServiceLocator.registerFactory<DesignSystemBloc>(
          () => DesignSystemBloc(
            MockGetDesignSystemUseCase()..stubCall(null),
            MockSetDesignSystemUseCase(),
            MockResetDesignSystemUseCase(),
          ),
        );
        addTearDown(appServiceLocator.reset);

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: ScreenFooterProviderWidget(
              footer: const Text('footer'),
              child: BlocProvider<DeveloperMenuBloc>.value(
                value: bloc,
                child: const ContentWidget(),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(
          find.descendant(
            of: find.byType(CustomScrollView),
            matching: find.text('Controls & Tools'),
          ),
          findsOneWidget,
        );
        await tester.scrollUntilVisible(
          find.text('footer', skipOffstage: false),
          200,
        );
        expect(
          tester.getTopLeft(find.text('footer', skipOffstage: false)).dy,
          greaterThan(
            tester.getBottomLeft(find.text('Force Blacklist Error')).dy,
          ),
        );
        expect(find.byType(FooterWidget), findsNothing);
      },
    );
  });
}
