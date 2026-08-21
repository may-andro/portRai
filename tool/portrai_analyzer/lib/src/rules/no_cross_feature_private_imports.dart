import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// A rule that forbids importing (or exporting) another feature's private
/// barrel files.
///
/// Within `app/portrai`, each feature lives under
/// `lib/src/feature/<feature_name>/` and organizes its internal files using
/// barrel files whose name starts with an underscore (for example
/// `_bloc.dart`, `_widget.dart`, `_domain.dart`). These barrels aggregate
/// files within that same feature, and are considered private to it. A
/// feature exposes its public API through its own top-level, non-underscore
/// barrel (for example `lib/src/feature/experience/experience.dart`).
///
/// Reaching into another feature's underscore-prefixed barrels (or any file
/// they transitively organize) bypasses that public API and couples features
/// to each other's internal file layout. Importing (or exporting) a private
/// barrel from within the *same* feature is unaffected by this rule, since
/// that's exactly how a feature's own barrels are meant to be composed.
class NoCrossFeaturePrivateImports extends AnalysisRule {
  NoCrossFeaturePrivateImports()
    : super(
        name: 'no_cross_feature_private_imports',
        description:
            "Disallows importing another feature's private, underscore-"
            'prefixed barrel files; only its public API should be imported.',
      );

  static const LintCode code = LintCode(
    'no_cross_feature_private_imports',
    "The import of '{0}' reaches into another feature's private barrel "
        'file.',
    correctionMessage:
        "Import that feature's public API instead of its private barrel "
        'file.',
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
    registry.addExportDirective(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;

  final RuleContext context;

  /// The path segment under which individual features live, as in
  /// `package:portrai/src/feature/<feature_name>/...`.
  static const _featureSegment = 'feature';

  @override
  void visitImportDirective(ImportDirective node) => _checkDirective(node);

  @override
  void visitExportDirective(ExportDirective node) => _checkDirective(node);

  void _checkDirective(NamespaceDirective node) {
    var referencedUri = node.uri.stringValue;
    if (referencedUri == null) return;

    var fileName = _fileNameOf(referencedUri);
    if (fileName == null || !fileName.startsWith('_')) return;

    var referencedFeatureRoot = _featureRootOf(referencedUri);
    // Not under a `feature/<name>` directory; this rule doesn't apply.
    if (referencedFeatureRoot == null) return;

    var currentUri = context.libraryElement?.uri.toString();
    if (currentUri == null) return;
    var currentFeatureRoot = _featureRootOf(currentUri);

    // Allow a feature to import/export its own private barrels.
    if (currentFeatureRoot == referencedFeatureRoot) return;

    rule.reportAtNode(node, arguments: [fileName]);
  }

  static String? _fileNameOf(String uriString) {
    var slashIndex = uriString.lastIndexOf('/');
    if (slashIndex == -1) return null;
    return uriString.substring(slashIndex + 1);
  }

  /// Returns the feature root of [uriString], e.g.
  /// `package:portrai/src/feature/experience` for
  /// `package:portrai/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart`,
  /// or `null` if [uriString] isn't located under a `feature/<name>`
  /// directory.
  static String? _featureRootOf(String uriString) {
    var segments = uriString.split('/');
    var featureIndex = segments.indexOf(_featureSegment);
    if (featureIndex == -1 || featureIndex + 1 >= segments.length) return null;
    return segments.sublist(0, featureIndex + 2).join('/');
  }
}
