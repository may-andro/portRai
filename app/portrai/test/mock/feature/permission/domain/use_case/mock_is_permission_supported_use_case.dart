import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/permission/permission.dart';
import 'package:use_case/use_case.dart';

class MockIsPermissionSupportedUseCase extends Mock
    implements IsPermissionSupportedUseCase {}

extension MockIsPermissionSupportedUseCaseStub
    on MockIsPermissionSupportedUseCase {
  void stubCall(AppPermission permission, {required bool isSupported}) {
    when(() => this(permission)).thenAnswer((_) => Right(isSupported));
  }
}
