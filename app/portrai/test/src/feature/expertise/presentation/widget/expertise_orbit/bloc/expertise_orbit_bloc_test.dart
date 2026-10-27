import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_orbit/bloc/_bloc.dart';

import '../../../../../../../mock/feature/expertise/presentation/widget/expertise_orbit/tracking/mock_expertise_orbit_tracking_delegate.dart';

void main() {
  group('ExpertiseOrbitBloc', () {
    late MockExpertiseOrbitTrackingDelegate tracking;

    ExpertiseOrbitBloc buildBloc() => ExpertiseOrbitBloc(tracking);

    setUp(() => tracking = MockExpertiseOrbitTrackingDelegate());

    blocTest<ExpertiseOrbitBloc, ExpertiseOrbitState>(
      'should track the tapped item without changing the state when an item '
      'is tapped',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ExpertiseOrbitClickEvent('Flutter Development')),
      expect: () => const <ExpertiseOrbitState>[],
      verify: (_) => verify(
        () => tracking.trackExpertiseClick('Flutter Development'),
      ).called(1),
    );
  });
}
