import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';

class FakeGenerateCvPdfParam extends Fake implements GenerateCvPdfParam {}

class FakeShareCvPdfParam extends Fake implements ShareCvPdfParam {
  @override
  Uint8List get pdfBytes => Uint8List(0);
}
