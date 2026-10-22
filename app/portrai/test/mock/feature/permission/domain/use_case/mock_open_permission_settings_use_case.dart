import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/permission/permission.dart';
import 'package:use_case/use_case.dart';

class MockOpenPermissionSettingsUseCase extends Mock
    implements OpenPermissionSettingsUseCase {}

extension MockOpenPermissionSettingsUseCaseStub
    on MockOpenPermissionSettingsUseCase {
  void stubCall(Either<OpenPermissionSettingsFailure, void> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
