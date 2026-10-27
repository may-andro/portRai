import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/developer_mode/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGetTrackingEventsUseCase extends Mock
    implements GetTrackingEventsUseCase {}

extension MockGetTrackingEventsUseCaseStub on MockGetTrackingEventsUseCase {
  /// Stubs `call()` to return [result].
  void stubCall(
    Either<GetTrackingEventsFailure, List<TrackingEventEntity>> result,
  ) {
    when(() => this()).thenAnswer((_) => result);
  }
}
