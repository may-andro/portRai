import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:use_case/use_case.dart';

class MockGenerateCvPdfUseCase extends Mock implements GenerateCvPdfUseCase {}

extension MockGenerateCvPdfUseCaseStub on MockGenerateCvPdfUseCase {
  void stubCall(Either<GenerateCvPdfFailure, Uint8List> result) {
    when(() => this(any())).thenAnswer((_) => result);
  }
}
