import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/cv_export/data/_data.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';

void main() {
  group('CvTailoringMapper', () {
    const mapper = CvTailoringMapper();

    test('should map every field of the response', () {
      final model = CvTailoringModel.fromJson({
        'summary': 'Flutter engineer.',
        'projectOrder': [2, 0],
        'skillGroupOrder': [1],
        'prioritizedSkills': ['Dart'],
      });

      expect(
        mapper.map(model),
        const CvTailoringEntity(
          summary: 'Flutter engineer.',
          projectOrder: [2, 0],
          skillGroupOrder: [1],
          prioritizedSkills: ['Dart'],
        ),
      );
    });

    test('should map missing orders to empty lists', () {
      final model = CvTailoringModel.fromJson({'summary': 'Summary.'});

      expect(mapper.map(model), const CvTailoringEntity(summary: 'Summary.'));
    });
  });
}
