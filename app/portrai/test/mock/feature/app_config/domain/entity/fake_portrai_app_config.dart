import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';

/// Fake used to register a fallback value for [PortraiAppConfig], since
/// mocktail needs one to match `any()` arguments of this type.
class FakePortraiAppConfig extends Fake implements PortraiAppConfig {}
