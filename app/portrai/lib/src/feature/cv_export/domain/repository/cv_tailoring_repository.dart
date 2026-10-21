import 'package:portrai/src/feature/cv_export/domain/entity/_entity.dart';

abstract interface class CvTailoringRepository {
  Future<CvTailoringEntity> tailor({
    required CvDocumentEntity document,
    required CvTailoringTargetEntity target,
  });
}
