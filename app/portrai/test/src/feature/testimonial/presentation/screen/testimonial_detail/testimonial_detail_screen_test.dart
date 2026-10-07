import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/_testimonial_detail.dart';
import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

import '../../../../../../mock/feature/testimonial/presentation/screen/testimonial_detail/bloc/mock_testimonial_detail_bloc.dart';
import '../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('TestimonialDetailScreen', () {
    setUp(() async {
      await appServiceLocator.reset();
    });

    tearDown(() async {
      await appServiceLocator.reset();
    });

    testWidgets(
      'should resolve the bloc from the service locator and dispatch the visible event',
      (tester) async {
        final bloc = MockTestimonialDetailBloc()
          ..stubState(const LoadingState());
        appServiceLocator.registerFactory<TestimonialDetailBloc>(() => bloc);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            navigatorObservers: [routeObserver],
            builder: (_, child) {
              return DSThemeBuilderWidget(
                brightness: Brightness.light,
                designSystem: DesignSystem.beltane,
                child: child!,
              );
            },
            home: const TestimonialDetailScreen(),
          ),
        );
        await tester.pump();

        expect(find.byType(Placeholder), findsOneWidget);
        verify(() => bloc.add(ScreenVisibleEvent())).called(1);
      },
    );
  });
}
