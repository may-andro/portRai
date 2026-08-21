import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that forbids importing another package's internal ('src')
/// implementation files.
///
/// Every package in the portrai workspace (e.g. `layer/core`, `layer/cache`,
/// ...) exposes its public API through one or more top-level library files in
/// `lib/`, while implementation details live under `lib/src/`. Reaching into
/// another package's `lib/src/` directory bypasses that public API and
/// couples modules to implementation details that may change at any time.
///
/// Importing a package's own `lib/src/` files (for example from that same
/// package's `test/` directory) is unaffected by this rule.
class NoCrossModuleInternalImports extends AnalysisRule {
  NoCrossModuleInternalImports()
    : super(
        name: 'no_cross_module_internal_imports',
        description:
            "Disallows importing another package's 'lib/src' internals; "
            'only its public API should be imported.',
      );

  static const LintCode code = LintCode(
    'no_cross_module_internal_imports',
    "The import of '{0}' reaches into another package's internal "
        "'src' directory.",
    correctionMessage:
        'Import the public API of that package instead of its internal '
        'implementation.',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    var visitor = _Visitor(this, context);
    registry.addImportDirective(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;

  final RuleContext context;

  @override
  void visitImportDirective(ImportDirective node) {
    var importedUri = node.uri.stringValue;
    if (importedUri == null) return;

    var importedPackage = _packageNameOf(importedUri);
    if (importedPackage == null) return;
    if (!_isInternalImport(importedUri)) return;

    var currentPackage = _packageNameOf(
      context.libraryElement?.uri.toString(),
    );
    // Allow a package to import its own 'src' files (e.g. from its 'test'
    // directory), and don't report when the current library's package can't
    // be determined.
    if (currentPackage == null || currentPackage == importedPackage) return;

    rule.reportAtNode(node, arguments: [importedUri]);
  }

  /// Extracts the package name out of a `package:` URI string, or `null` if
  /// [uriString] isn't a `package:` URI.
  static String? _packageNameOf(String? uriString) {
    if (uriString == null || !uriString.startsWith('package:')) return null;
    var pathWithoutScheme = uriString.substring('package:'.length);
    var slashIndex = pathWithoutScheme.indexOf('/');
    if (slashIndex == -1) return null;
    return pathWithoutScheme.substring(0, slashIndex);
  }

  /// Whether [uriString] points into a package's internal 'src' directory,
  /// that is, `package:some_package/src/...`.
  static bool _isInternalImport(String uriString) {
    var pathWithoutScheme = uriString.substring('package:'.length);
    var firstSlash = pathWithoutScheme.indexOf('/');
    if (firstSlash == -1) return false;
    var rest = pathWithoutScheme.substring(firstSlash + 1);
    return rest == 'src' || rest.startsWith('src/');
  }
}
