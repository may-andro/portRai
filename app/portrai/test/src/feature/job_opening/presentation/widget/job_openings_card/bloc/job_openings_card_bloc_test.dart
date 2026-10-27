import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/job_openings_card/bloc/_bloc.dart';

import '../../../../../../../mock/feature/job_opening/presentation/widget/job_openings_card/tracking/mock_job_openings_card_tracking_delegate.dart';

void main() {
  group('JobOpeningsCardBloc', () {
    late MockJobOpeningsCardTrackingDelegate tracking;

    JobOpeningsCardBloc buildBloc() => JobOpeningsCardBloc(tracking);

    setUp(() => tracking = MockJobOpeningsCardTrackingDelegate());

    blocTest<JobOpeningsCardBloc, JobOpeningsCardState>(
      'should track the tap without changing the state when the card is '
      'tapped',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const JobOpeningsCardClickEvent('job_openings_card')),
      expect: () => const <JobOpeningsCardState>[],
      verify: (_) => verify(
        () => tracking.trackJobOpeningsClick('job_openings_card'),
      ).called(1),
    );
  });
}
