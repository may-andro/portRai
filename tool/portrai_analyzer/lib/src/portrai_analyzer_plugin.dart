import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:portrai_analyzer/src/rules/no_cross_feature_private_imports.dart';
import 'package:portrai_analyzer/src/rules/no_cross_module_internal_imports.dart';

class PortraiAnalyzerPlugin extends Plugin {
  @override
  String get name => 'portrai_analyzer';

  @override
  void register(PluginRegistry registry) {
    registry.registerWarningRule(NoCrossModuleInternalImports());
    registry.registerWarningRule(NoCrossFeaturePrivateImports());
  }
}
