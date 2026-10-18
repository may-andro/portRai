import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/exception/_exception.dart';
import 'package:portrai/src/feature/cv_export/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

/// Input of [GenerateCvPdfUseCase]. Its [toString] leaves the personal
/// content out because use case parameters are logged.
class GenerateCvPdfParam {
  const GenerateCvPdfParam({
    required this.document,
    required this.options,
    required this.labels,
  });

  final CvDocumentEntity document;
  final CvOptionsEntity options;
  final CvLabelsEntity labels;

  @override
  String toString() {
    return 'GenerateCvPdfParam(template: ${options.template.name}, '
        'accent: ${options.accent.name}, '
        'isPhotoIncluded: ${options.isPhotoIncluded}, '
        'sections: ${options.sections.map((section) => section.name)})';
  }
}

sealed class GenerateCvPdfFailure extends BasicFailure {
  const GenerateCvPdfFailure({super.cause});
}

@Localizable('errorCvPdfGeneration')
class CvPdfGenerationFailure extends GenerateCvPdfFailure {
  const CvPdfGenerationFailure({super.cause});
}

@Localizable('errorCvUnknown')
class UnknownGenerateCvPdfFailure extends GenerateCvPdfFailure {
  const UnknownGenerateCvPdfFailure({super.cause});
}

@register
class GenerateCvPdfUseCase
    extends BaseUseCase<Uint8List, GenerateCvPdfParam, GenerateCvPdfFailure> {
  GenerateCvPdfUseCase(this._repository);

  final CvPdfRepository _repository;

  @protected
  @override
  Future<Either<GenerateCvPdfFailure, Uint8List>> execute(
    GenerateCvPdfParam input,
  ) async {
    final pdfBytes = await _repository.generatePdf(
      document: input.document,
      options: input.options,
      labels: input.labels,
    );
    return Right(pdfBytes);
  }

  @protected
  @override
  GenerateCvPdfFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      CvPdfGenerationException() => CvPdfGenerationFailure(cause: e),
      _ => UnknownGenerateCvPdfFailure(cause: e),
    };
  }
}
