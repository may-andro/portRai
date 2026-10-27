import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/presentation/widget/experience_list/bloc/_bloc.dart';

import '../../../../../../../mock/feature/experience/presentation/widget/experience_list/tracking/mock_experience_list_tracking_delegate.dart';

void main() {
  group('ExperienceListBloc', () {
    late MockExperienceListTrackingDelegate tracking;

    ExperienceListBloc buildBloc() => ExperienceListBloc(tracking);

    setUp(() => tracking = MockExperienceListTrackingDelegate());

    blocTest<ExperienceListBloc, ExperienceListState>(
      'should track the tapped item without changing the state when an item '
      'is tapped',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ExperienceClickEvent(
          label: 'experience_card',
          experienceId: 'id_0',
        ),
      ),
      expect: () => const <ExperienceListState>[],
      verify: (_) => verify(
        () => tracking.trackExperienceClick(
          label: 'experience_card',
          experienceId: 'id_0',
        ),
      ).called(1),
    );
  });
}
