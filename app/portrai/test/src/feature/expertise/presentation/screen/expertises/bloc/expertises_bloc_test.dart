import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/bloc/_bloc.dart';

import '../../../../../../../mock/feature/expertise/domain/use_case/mock_get_all_expertise_use_case.dart';
import '../../../../../../../mock/feature/expertise/presentation/screen/expertises/tracking/mock_expertises_tracking_delegate.dart';

void main() {
  group('ExpertisesBloc', () {
    late MockGetAllExpertiseUseCase getAllExpertise;
    late MockExpertisesTrackingDelegate tracking;

    ExpertisesBloc buildBloc() => ExpertisesBloc(getAllExpertise, tracking);

    setUp(() {
      getAllExpertise = MockGetAllExpertiseUseCase();
      tracking = MockExpertisesTrackingDelegate();
    });

    blocTest<ExpertisesBloc, ExpertisesState>(
      'should track the opened item without changing the state when an item '
      'is tapped',
      build: buildBloc,
      act: (bloc) => bloc.add(const ExpertiseClickEvent('Flutter Development')),
      expect: () => const <ExpertisesState>[],
      verify: (_) => verify(
        () => tracking.trackExpertiseClick('Flutter Development'),
      ).called(1),
    );
  });
}
