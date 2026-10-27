import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_list/bloc/_bloc.dart';

import '../../../../../../../mock/feature/expertise/presentation/widget/expertise_list/tracking/mock_expertise_list_tracking_delegate.dart';

void main() {
  group('ExpertiseListBloc', () {
    late MockExpertiseListTrackingDelegate tracking;

    ExpertiseListBloc buildBloc() => ExpertiseListBloc(tracking);

    setUp(() => tracking = MockExpertiseListTrackingDelegate());

    blocTest<ExpertiseListBloc, ExpertiseListState>(
      'should track the tapped item without changing the state when an item '
      'is tapped',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ExpertiseClickEvent(
          label: 'expertise_card',
          expertiseTitle: 'Flutter Development',
        ),
      ),
      expect: () => const <ExpertiseListState>[],
      verify: (_) => verify(
        () => tracking.trackExpertiseClick(
          label: 'expertise_card',
          expertiseTitle: 'Flutter Development',
        ),
      ).called(1),
    );
  });
}
