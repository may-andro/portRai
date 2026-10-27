import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/service/presentation/widget/service_list/bloc/_bloc.dart';

import '../../../../../../../mock/feature/service/presentation/widget/service_list/tracking/mock_service_list_tracking_delegate.dart';

void main() {
  group('ServiceListBloc', () {
    late MockServiceListTrackingDelegate tracking;

    ServiceListBloc buildBloc() => ServiceListBloc(tracking);

    setUp(() => tracking = MockServiceListTrackingDelegate());

    blocTest<ServiceListBloc, ServiceListState>(
      'should track the tapped item without changing the state when an item '
      'is tapped',
      build: buildBloc,
      act: (bloc) => bloc.add(const ServiceClickEvent('App Development')),
      expect: () => const <ServiceListState>[],
      verify: (_) =>
          verify(() => tracking.trackServiceClick('App Development')).called(1),
    );
  });
}
