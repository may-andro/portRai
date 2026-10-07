import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/_project.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../mock/feature/project/presentation/screen/project/bloc/mock_project_bloc.dart';
import '../../../../../../mock/feature/project/test_data/project_test_data.dart';
import '../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('ProjectScreen', () {
    setUp(() async {
      await appServiceLocator.reset();
    });

    tearDown(() async {
      await appServiceLocator.reset();
    });

    testWidgets(
      'should resolve the bloc from the service locator and dispatch the load event',
      (tester) async {
        final bloc = MockProjectBloc()..stubState(const LoadingState());
        appServiceLocator.registerFactory<ProjectBloc>(() => bloc);
        final project = createProjectEntity();

        await tester.pumpWidget(
          TestWidgetWrapper(child: ProjectScreen(project: project)),
        );
        await tester.pump();

        expect(find.byType(DSLoadingWidget), findsOneWidget);
        verify(() => bloc.add(LoadProjectEvent(project))).called(1);
      },
    );
  });
}
