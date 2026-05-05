import 'package:firestore_export_import/use_case/get_api_header_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockGetApiHeaderUseCase extends Mock implements GetApiHeaderUseCase {
  void mockExecute(Map<String, String> mockHeaders) {
    when(() => execute(any())).thenAnswer((_) async => mockHeaders);
  }
}
