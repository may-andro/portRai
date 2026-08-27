import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/external_app_handler/domain/_domain.dart';

/// Fake used to register a fallback value for [OpenExternalUrlParam], since
/// mocktail needs one to match `any()` arguments of this type.
class FakeOpenExternalUrlParam extends Fake implements OpenExternalUrlParam {}
