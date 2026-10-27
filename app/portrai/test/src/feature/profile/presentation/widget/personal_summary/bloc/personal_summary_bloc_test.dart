import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/presentation/widget/personal_summary/bloc/_bloc.dart';

import '../../../../../../../mock/feature/profile/presentation/widget/personal_summary/tracking/mock_personal_summary_tracking_delegate.dart';

void main() {
  group('PersonalSummaryBloc', () {
    late MockPersonalSummaryTrackingDelegate tracking;

    PersonalSummaryBloc buildBloc() => PersonalSummaryBloc(tracking);

    setUp(() => tracking = MockPersonalSummaryTrackingDelegate());

    blocTest<PersonalSummaryBloc, PersonalSummaryState>(
      'should track the view profile tap without changing the state when the '
      'view full profile button is tapped',
      build: buildBloc,
      act: (bloc) => bloc.add(const ViewProfileClickEvent()),
      expect: () => const <PersonalSummaryState>[],
      verify: (_) => verify(() => tracking.trackViewProfileClick()).called(1),
    );
  });
}
