import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/cv_export/domain/exception/_exception.dart';
import 'package:portrai/src/feature/cv_export/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

/// Input of [ShareCvPdfUseCase]. Its [toString] leaves the PDF content out
/// because use case parameters are logged.
class ShareCvPdfParam {
  const ShareCvPdfParam({required this.pdfBytes, required this.fileName});

  final Uint8List pdfBytes;
  final String fileName;

  @override
  String toString() {
    return 'ShareCvPdfParam(fileName: $fileName, '
        'sizeInBytes: ${pdfBytes.lengthInBytes})';
  }
}

sealed class ShareCvPdfFailure extends BasicFailure {
  const ShareCvPdfFailure({super.cause});
}

@Localizable('errorCvPdfShare')
class CvPdfShareFailure extends ShareCvPdfFailure {
  const CvPdfShareFailure({super.cause});
}

@Localizable('errorCvUnknown')
class UnknownShareCvPdfFailure extends ShareCvPdfFailure {
  const UnknownShareCvPdfFailure({super.cause});
}

@register
class ShareCvPdfUseCase
    extends BaseUseCase<bool, ShareCvPdfParam, ShareCvPdfFailure> {
  ShareCvPdfUseCase(this._repository);

  final CvPdfRepository _repository;

  @protected
  @override
  Future<Either<ShareCvPdfFailure, bool>> execute(ShareCvPdfParam input) async {
    final isShared = await _repository.sharePdf(
      pdfBytes: input.pdfBytes,
      fileName: input.fileName,
    );
    return Right(isShared);
  }

  @protected
  @override
  ShareCvPdfFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      CvPdfShareException() => CvPdfShareFailure(cause: e),
      _ => UnknownShareCvPdfFailure(cause: e),
    };
  }
}
