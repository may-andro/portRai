import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/permission/permission.dart';
import 'package:use_case/use_case.dart';

class MockGetPermissionStatusUseCase extends Mock
    implements GetPermissionStatusUseCase {}

extension MockGetPermissionStatusUseCaseStub on MockGetPermissionStatusUseCase {
  void stubCall(
    AppPermission permission,
    Either<GetPermissionStatusFailure, AppPermissionStatus> result,
  ) {
    when(() => this(permission)).thenAnswer((_) => result);
  }
}
