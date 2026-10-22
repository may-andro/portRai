import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/bloc/_bloc.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/widget/content_widget.dart';
import 'package:portrai/src/feature/service/presentation/widget/service_list/service_list.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

import '../../../../../../../mock/feature/service/presentation/screen/services/bloc/mock_services_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  Future<MockServicesBloc> pump(
    WidgetTester tester,
    ServicesState state,
  ) async {
    final bloc = MockServicesBloc()..stubState(state);
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: ScreenFooterProviderWidget(
          footer: const Text('footer'),
          child: BlocProvider<ServicesBloc>.value(
            value: bloc,
            child: const ContentWidget(),
          ),
        ),
      ),
    );
    await tester.pump();
    return bloc;
  }

  group('Services ContentWidget', () {
    testWidgets('should render loading and track its impression when loading', (
      tester,
    ) async {
      final bloc = await pump(tester, const LoadingState());

      expect(find.byType(DSLoadingWidget), findsOneWidget);
      verify(
        () => bloc.add(const ViewStateVisibleEvent('loading_content_view')),
      ).called(1);
    });

    testWidgets(
      'should render an error card and track its impression when loading fails',
      (tester) async {
        final bloc = await pump(
          tester,
          const ErrorState(failure: ServicesNotFoundFailure()),
        );

        expect(find.byType(DSErrorCardWidget), findsOneWidget);
        verify(
          () => bloc.add(const ViewStateVisibleEvent('error_content_view')),
        ).called(1);
      },
    );

    testWidgets('should render the service list when loading succeeds', (
      tester,
    ) async {
      final bloc = await pump(tester, const LoadedState(services: []));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(ServiceListWidget), findsOneWidget);
      verify(
        () => bloc.add(const ViewStateVisibleEvent('loaded_content_view')),
      ).called(1);
    });

    testWidgets(
      'should end the shared scroll view with the provided footer when loading succeeds',
      (tester) async {
        await pump(tester, const LoadedState(services: []));
        await tester.pump(const Duration(seconds: 1));

        final scrollView = find.byType(CustomScrollView);
        expect(scrollView, findsOneWidget);
        expect(
          find.descendant(
            of: scrollView,
            matching: find.byType(ServiceListWidget),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: scrollView, matching: find.text('footer')),
          findsOneWidget,
        );
        expect(
          tester.getTopLeft(find.text('footer')).dy,
          greaterThanOrEqualTo(
            tester.getBottomLeft(find.byType(ServiceListWidget)).dy,
          ),
        );
        expect(find.byType(FooterWidget), findsNothing);
      },
    );
  });
}
