import 'package:firestore_export_import/use_case/get_auth_token_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAuthTokenUseCase extends Mock implements GetAuthTokenUseCase {
  void mockExecute(String expected) {
    when(() => execute(any())).thenAnswer((_) async => expected);
  }
}
