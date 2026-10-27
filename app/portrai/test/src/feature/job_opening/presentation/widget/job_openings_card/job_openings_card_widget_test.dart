import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/presentation/route/_route.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/job_openings_card/bloc/_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/job_openings_card/job_openings_card_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../mock/feature/job_opening/presentation/widget/job_openings_card/bloc/mock_job_openings_card_bloc.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  late MockJobOpeningsCardBloc bloc;

  setUp(() async {
    await appServiceLocator.reset();
    bloc = MockJobOpeningsCardBloc()
      ..stubState()
      ..registerFactory();
  });

  tearDown(() => appServiceLocator.reset());

  testWidgets('should track the tap and open the job openings when the card '
      'is tapped', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: JobOpeningsCardWidget()),
        ),
        GoRoute(
          name: JobOpeningModuleRoute.jobOpenings.name,
          path: JobOpeningModuleRoute.jobOpenings.path,
          builder: (_, _) => const Text('Job openings screen'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      TestWidgetWrapper(routerConfig: router, child: const SizedBox()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Job openings'));
    await tester.pumpAndSettle();

    verify(
      () => bloc.add(const JobOpeningsCardClickEvent('job_openings_card')),
    ).called(1);
    expect(find.text('Job openings screen'), findsOneWidget);
  });
}
