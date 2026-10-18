import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockShareCvPdfUseCase extends Mock implements ShareCvPdfUseCase {}

extension MockShareCvPdfUseCaseStub on MockShareCvPdfUseCase {
  void stubCall(Either<ShareCvPdfFailure, bool> result) {
    when(() => this(any())).thenAnswer((_) => result);
  }
}
