import 'package:firestore_export_import/use_case/upload_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockUploadUseCase extends Mock implements UploadUseCase {
  void mockExecute(Future<void> Function() answer) {
    when(() => execute(any(), any(), any())).thenAnswer((_) => answer());
  }
}
