import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockWatchDeviceTokenRefreshesUseCase extends Mock
    implements WatchDeviceTokenRefreshesUseCase {}

extension MockWatchDeviceTokenRefreshesUseCaseStub
    on MockWatchDeviceTokenRefreshesUseCase {
  void stubCall(
    Stream<Either<WatchDeviceTokenRefreshesFailure, String>> stream,
  ) {
    when(() => this()).thenAnswer((_) => stream);
  }
}
