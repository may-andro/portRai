import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/presentation/widget/project_list/bloc/_bloc.dart';

import '../../../../../../../mock/feature/project/presentation/widget/project_list/tracking/mock_project_list_tracking_delegate.dart';

void main() {
  group('ProjectListBloc', () {
    late MockProjectListTrackingDelegate tracking;

    ProjectListBloc buildBloc() => ProjectListBloc(tracking);

    setUp(() => tracking = MockProjectListTrackingDelegate());

    blocTest<ProjectListBloc, ProjectListState>(
      'should track the tapped item without changing the state when an item '
      'is tapped',
      build: buildBloc,
      act: (bloc) => bloc.add(const ProjectClickEvent('port-rai')),
      expect: () => const <ProjectListState>[],
      verify: (_) =>
          verify(() => tracking.trackProjectClick('port-rai')).called(1),
    );
  });
}
