import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/permission/permission.dart';
import 'package:use_case/use_case.dart';

class MockRequestPermissionUseCase extends Mock
    implements RequestPermissionUseCase {}

extension MockRequestPermissionUseCaseStub on MockRequestPermissionUseCase {
  void stubCall(
    AppPermission permission,
    Either<RequestPermissionFailure, AppPermissionStatus> result,
  ) {
    when(() => this(permission)).thenAnswer((_) => result);
  }
}
