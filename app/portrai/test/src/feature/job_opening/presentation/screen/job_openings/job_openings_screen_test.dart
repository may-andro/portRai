import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/_job_openings.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../mock/feature/job_opening/presentation/screen/job_openings/bloc/mock_job_openings_bloc.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  testWidgets('should open the start page when the user signed out', (
    tester,
  ) async {
    final bloc = MockJobOpeningsBloc();
    whenListen(
      bloc,
      Stream.value(
        const JobOpeningsState(
          status: JobOpeningsStatus.loaded,
          isSignedOut: true,
        ),
      ),
      initialState: const JobOpeningsState(status: JobOpeningsStatus.loaded),
    );
    await appServiceLocator.reset();
    addTearDown(appServiceLocator.reset);
    appServiceLocator.registerFactory<JobOpeningsBloc>(() => bloc);

    final router = GoRouter(
      initialLocation: '/job-openings',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('Home')),
        GoRoute(
          path: '/job-openings',
          builder: (_, _) => const JobOpeningsScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      TestWidgetWrapper(routerConfig: router, child: const SizedBox()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });
}
