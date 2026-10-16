import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/app_config/data/model/_model.dart';

/// Fake used to register a fallback value for [PortraiAppConfigModel], since
/// mocktail needs one to match `any()` arguments of this type.
class FakePortraiAppConfigModel extends Fake implements PortraiAppConfigModel {}
