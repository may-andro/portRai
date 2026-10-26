import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/_widget.dart';

import '../../../../../util/test_wrapper_widget.dart';

void main() {
  group('JobFitTier', () {
    for (final (score, tier) in [
      (100, JobFitTier.strong),
      (80, JobFitTier.strong),
      (79, JobFitTier.good),
      (70, JobFitTier.good),
      (69, JobFitTier.possible),
      (0, JobFitTier.possible),
    ]) {
      test('should place a score of $score in the ${tier.name} tier', () {
        expect(JobFitTier.of(score), tier);
      });
    }
  });

  group('JobFitScoreWidget', () {
    testWidgets('should show the full score at once when not animated', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: JobFitScoreWidget(score: 82, isAnimated: false),
        ),
      );

      expect(find.text('82'), findsOneWidget);
    });

    testWidgets('should count up from zero when animated', (tester) async {
      await tester.pumpWidget(
        const TestWidgetWrapper(child: JobFitScoreWidget(score: 82)),
      );

      expect(find.text('0'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('82'), findsOneWidget);
    });
  });
}
