import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockTailorCvDocumentUseCase extends Mock
    implements TailorCvDocumentUseCase {}

class FakeTailorCvDocumentParam extends Fake implements TailorCvDocumentParam {}

extension MockTailorCvDocumentUseCaseStub on MockTailorCvDocumentUseCase {
  void stubCall(Either<TailorCvDocumentFailure, CvDocumentEntity> result) {
    when(() => this(any())).thenAnswer((_) => Future.value(result));
  }
}
