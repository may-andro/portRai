import 'package:flutter_test/flutter_test.dart';

import '../../../../../mock/feature/portfolio/test_data/portfolio_test_data.dart';

void main() {
  group('PortfolioEntity', () {
    test('should compare equal when all portfolio fields match', () {
      expect(createPortfolioEntity(), createPortfolioEntity());
      expect(
        createPortfolioEntity().hashCode,
        createPortfolioEntity().hashCode,
      );
    });

    test('should not compare equal when a field differs', () {
      expect(
        createPortfolioEntity(),
        isNot(createPortfolioEntity(projects: const [])),
      );
    });
  });
}
