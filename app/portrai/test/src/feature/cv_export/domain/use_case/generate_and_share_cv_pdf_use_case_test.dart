import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';

import '../../../../../mock/feature/cv_export/domain/repository/mock_cv_pdf_repository.dart';
import '../../../../../util/cv_export_test_fixture.dart';

void main() {
  setUpAll(registerCvPdfRepositoryFallbackValues);

  group('GenerateCvPdfUseCase', () {
    late MockCvPdfRepository repository;
    late GenerateCvPdfUseCase useCase;
    final param = GenerateCvPdfParam(
      document: CvExportTestFixture.lightDocument(),
      options: const CvOptionsEntity(),
      labels: CvExportTestFixture.labels,
    );

    setUp(() {
      repository = MockCvPdfRepository();
      useCase = GenerateCvPdfUseCase(repository);
    });

    test('should return the pdf bytes when the repository succeeds', () async {
      final pdfBytes = Uint8List.fromList([1, 2, 3]);
      repository.stubGeneratePdf(pdfBytes);

      final result = await useCase(param);

      expect(result.right, pdfBytes);
    });

    test(
      'should fail with generation failure when the pdf cannot be built',
      () async {
        repository.stubGeneratePdfError(const CvPdfGenerationException('nope'));

        final result = await useCase(param);

        expect(result.left, isA<CvPdfGenerationFailure>());
      },
    );

    test(
      'should fail with unknown failure when something unexpected happens',
      () async {
        repository.stubGeneratePdfError(StateError('boom'));

        final result = await useCase(param);

        expect(result.left, isA<UnknownGenerateCvPdfFailure>());
      },
    );

    test('should hide personal data when the param is printed', () {
      expect(param.toString(), isNot(contains('Ada')));
      expect(param.toString(), contains('sidebar'));
    });
  });

  group('ShareCvPdfUseCase', () {
    late MockCvPdfRepository repository;
    late ShareCvPdfUseCase useCase;
    final param = ShareCvPdfParam(
      pdfBytes: Uint8List.fromList([1, 2, 3]),
      fileName: 'Ada_CV.pdf',
    );

    setUp(() {
      repository = MockCvPdfRepository();
      useCase = ShareCvPdfUseCase(repository);
    });

    test(
      'should return whether it was shared when the repository succeeds',
      () async {
        repository.stubSharePdf(isShared: true);

        final result = await useCase(param);

        expect(result.right, isTrue);
      },
    );

    test('should fail with share failure when sharing throws', () async {
      repository.stubSharePdfError(const CvPdfShareException('nope'));

      final result = await useCase(param);

      expect(result.left, isA<CvPdfShareFailure>());
    });

    test('should only print the size when the param is printed', () {
      expect(param.toString(), contains('sizeInBytes: 3'));
    });
  });
}
