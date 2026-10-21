import 'package:portrai/src/feature/cv_export/domain/entity/_entity.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/cv_export_screen.dart';
import 'package:portrai/src/route/route.dart';

class CvExportModuleRoute extends ModuleRoute {
  const CvExportModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  static final CvExportModuleRoute cvExport = CvExportModuleRoute._(
    name: 'cv_export',
    path: '/cv-export',
    builder: (_, extra, _) => CvExportScreen(
      tailoringTarget: extra is CvTailoringTargetEntity ? extra : null,
    ),
  );
}
