import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:portrai_analyzer/src/rules/no_cross_module_internal_imports.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoCrossModuleInternalImportsTest);
  });
}

@reflectiveTest
class NoCrossModuleInternalImportsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoCrossModuleInternalImports();

    // `newPackage` must be called before `super.setUp()`.
    newPackage('other_module')
      ..addFile('lib/other_module.dart', 'class Public {}')
      ..addFile('lib/src/internal.dart', 'class Internal {}');

    super.setUp();

    newFile(
      '$testPackageLibPath/src/some_internal.dart',
      'class Internal {}',
    );
  }

  Future<void> test_crossModuleSrcImport() async {
    await assertDiagnostics(
      r'''
import 'package:other_module/src/internal.dart';

Internal? f() => null;
''',
      [lint(0, 48)],
    );
  }

  Future<void> test_crossModulePublicImport_noLint() async {
    await assertNoDiagnostics(r'''
import 'package:other_module/other_module.dart';

Public? f() => null;
''');
  }

  Future<void> test_ownPackageSrcImport_noLint() async {
    await assertNoDiagnostics(r'''
import 'package:test/src/some_internal.dart';

Internal? f() => null;
''');
  }

  Future<void> test_dartUriImport_noLint() async {
    await assertNoDiagnostics(r'''
import 'dart:async';

Future<void>? f;
''');
  }
}
