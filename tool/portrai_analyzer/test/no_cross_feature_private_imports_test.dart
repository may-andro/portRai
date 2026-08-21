import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:portrai_analyzer/src/rules/no_cross_feature_private_imports.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoCrossFeaturePrivateImportsTest);
  });
}

@reflectiveTest
class NoCrossFeaturePrivateImportsTest extends AnalysisRuleTest {
  // Places the file under test inside the 'project' feature, mirroring the
  // real `lib/src/feature/project/...` layout, so that "same feature" checks
  // are meaningful.
  @override
  String get testFileName => 'src/feature/project/project_section_dto.dart';

  @override
  void setUp() {
    rule = NoCrossFeaturePrivateImports();
    super.setUp();

    newFile(
      '$testPackageLibPath/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart',
      'class ExperienceBloc {}',
    );
    newFile(
      '$testPackageLibPath/src/feature/experience/experience.dart',
      'class ExperienceScreen {}',
    );
    newFile(
      '$testPackageLibPath/src/feature/project/domain/_domain.dart',
      'class ProjectEntity {}',
    );
    newFile(
      '$testPackageLibPath/src/feature/project/presentation/screen/project/widget/_widget.dart',
      'class ProjectWidget {}',
    );
    newFile('$testPackageLibPath/src/utility/_utility.dart', 'class Utility {}');
  }

  Future<void> test_crossFeaturePrivateImport() async {
    await assertDiagnostics(
      r'''
import 'package:test/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart';

ExperienceBloc? f() => null;
''',
      [lint(0, 92)],
    );
  }

  Future<void> test_crossFeaturePrivateExport() async {
    await assertDiagnostics(
      r'''
export 'package:test/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart';
''',
      [lint(0, 92)],
    );
  }

  Future<void> test_sameFeaturePrivateImport_noLint() async {
    await assertNoDiagnostics(r'''
import 'package:test/src/feature/project/domain/_domain.dart';

ProjectEntity? f() => null;
''');
  }

  Future<void> test_sameFeatureNestedPrivateImport_noLint() async {
    await assertNoDiagnostics(r'''
import 'package:test/src/feature/project/presentation/screen/project/widget/_widget.dart';

ProjectWidget? f() => null;
''');
  }

  Future<void> test_otherFeaturePublicImport_noLint() async {
    await assertNoDiagnostics(r'''
import 'package:test/src/feature/experience/experience.dart';

ExperienceScreen? f() => null;
''');
  }

  Future<void> test_nonFeatureUnderscoreImport_noLint() async {
    await assertNoDiagnostics(r'''
import 'package:test/src/utility/_utility.dart';

Utility? f() => null;
''');
  }
}
