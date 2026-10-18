import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockBuildCvDocumentUseCase extends Mock
    implements BuildCvDocumentUseCase {}

extension MockBuildCvDocumentUseCaseStub on MockBuildCvDocumentUseCase {
  void stubCall(Either<BuildCvDocumentFailure, CvDocumentEntity> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
