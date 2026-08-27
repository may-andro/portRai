// ignore_for_file: avoid_implementing_value_types
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';

/// Fake used to register a fallback value for [PortraiAppConfigEntity], since
/// mocktail needs one to match `any()` arguments of this type.
class FakePortraiAppConfigEntity extends Fake
    implements PortraiAppConfigEntity {}
