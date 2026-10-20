import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_rate_limit/data/model/_model.dart';

/// Fake used to register a fallback value for [AiRequestLogModel], since
/// mocktail needs one to match `any()` arguments of this type.
class FakeAiRequestLogModel extends Fake implements AiRequestLogModel {}
