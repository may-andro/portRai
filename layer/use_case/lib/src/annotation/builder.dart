import 'package:build/build.dart';
import 'package:use_case/src/annotation/failure_translator_generator.dart';

/// Builder factory for the failure translator generator.
///
/// This is referenced by build.yaml and used by build_runner to generate
/// the centralized FailureTranslator class from @Localizable annotations.
Builder failureTranslatorBuilder(BuilderOptions options) {
  return FailureTranslatorBuilder();
}
