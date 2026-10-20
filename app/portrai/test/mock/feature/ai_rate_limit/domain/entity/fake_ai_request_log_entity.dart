// ignore_for_file: avoid_implementing_value_types
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_rate_limit/domain/entity/_entity.dart';

/// Fake used to register a fallback value for [AiRequestLogEntity], since
/// mocktail needs one to match `any()` arguments of this type.
class FakeAiRequestLogEntity extends Fake implements AiRequestLogEntity {}
