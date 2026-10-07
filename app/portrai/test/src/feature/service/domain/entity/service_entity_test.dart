import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

void main() {
  const service = ServiceEntity(
    image: 'service.png',
    title: 'App Development',
    description: 'Beautiful apps',
    detail: 'Detailed service description',
  );

  group('ServiceEntity', () {
    test('should compare equal when all service fields match', () {
      expect(service, service);
      expect(service.hashCode, service.hashCode);
    });

    test('should not compare equal when a field differs', () {
      expect(
        service,
        isNot(
          const ServiceEntity(
            image: 'service.png',
            title: 'Other Service',
            description: 'Beautiful apps',
            detail: 'Detailed service description',
          ),
        ),
      );
    });
  });
}
