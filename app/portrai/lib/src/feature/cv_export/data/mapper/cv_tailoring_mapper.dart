import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/cv_export/data/model/_model.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/_entity.dart';

/// Maps one direction only: the app reads tailoring responses but never
/// writes them.
@register
class CvTailoringMapper implements Mapper<CvTailoringModel, CvTailoringEntity> {
  const CvTailoringMapper();

  @override
  CvTailoringEntity map(CvTailoringModel from) => CvTailoringEntity(
    summary: from.summary,
    projectOrder: from.projectOrder,
    skillGroupOrder: from.skillGroupOrder,
    prioritizedSkills: from.prioritizedSkills,
  );
}
