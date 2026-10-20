import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/ai_rate_limit/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/ai_rate_limit/data/model/_model.dart';
import 'package:portrai/src/feature/ai_rate_limit/domain/entity/_entity.dart';

void main() {
  group('AiRequestLogMapper', () {
    const mapper = AiRequestLogMapper();
    final firstRequestTime = DateTime(2026, 10, 20, 12);
    final secondRequestTime = DateTime(2026, 10, 20, 12, 0, 30);

    test('should map request times to the entity when the model has them', () {
      expect(
        mapper.to(
          AiRequestLogModel(
            requestTimesInMilliseconds: [
              firstRequestTime.millisecondsSinceEpoch,
              secondRequestTime.millisecondsSinceEpoch,
            ],
          ),
        ),
        AiRequestLogEntity(requestTimes: [firstRequestTime, secondRequestTime]),
      );
    });

    test('should keep the entity when it is mapped to a model and back', () {
      final aiRequestLog = AiRequestLogEntity(
        requestTimes: [firstRequestTime, secondRequestTime],
      );

      expect(mapper.to(mapper.from(aiRequestLog)), aiRequestLog);
    });
  });
}
