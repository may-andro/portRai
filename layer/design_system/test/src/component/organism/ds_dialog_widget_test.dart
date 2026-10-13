import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util/alchemist_utils.dart';
import '../../../util/test_wrapper_widget.dart';

void main() {
  group('DSDialogWidget constraints', () {
    testWidgets('should not throw when maxWidth is smaller than the default '
        'min width', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const TestWidgetWrapper(
          brightness: Brightness.light,
          designSystem: DesignSystem.beltane,
          child: DSDialogWidget(maxWidth: 200, child: Text('content')),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('should respect custom maxWidth when it is provided', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const TestWidgetWrapper(
          brightness: Brightness.light,
          designSystem: DesignSystem.beltane,
          child: DSDialogWidget(
            maxWidth: 640,
            child: SizedBox(width: 2000, height: 10),
          ),
        ),
      );

      final size = tester.getSize(find.byType(ConstrainedBox).last);
      expect(size.width, lessThanOrEqualTo(640));
    });
  });

  groupGoldenForBrightnessAndDS(
    'DSDialogWidget',
    (theme) => [
      TestCase(
        'with text content',
        DSDialogWidget(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSTextWidget(
                'Confirm Action',
                style: theme.typography.titleLarge,
                color: theme.colorPalette.neutral.grey9,
              ),
              const DSVerticalSpacerWidget(1),
              DSTextWidget(
                'Are you sure you want to proceed?',
                style: theme.typography.bodyMedium,
                color: theme.colorPalette.neutral.grey7,
              ),
            ],
          ),
        ),
      ),
      TestCase(
        'with action buttons',
        DSDialogWidget(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSTextWidget(
                'Delete Item',
                style: theme.typography.titleLarge,
                color: theme.colorPalette.neutral.grey9,
              ),
              const DSVerticalSpacerWidget(1),
              DSTextWidget(
                'This action cannot be undone.',
                style: theme.typography.bodyMedium,
                color: theme.colorPalette.neutral.grey7,
              ),
              const DSVerticalSpacerWidget(2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DSButtonWidget(
                    label: 'Cancel',
                    onPressed: () {},
                    variant: DSButtonVariant.text,
                    size: DSButtonSize.small,
                  ),
                  const SizedBox(width: 8),
                  DSButtonWidget(
                    label: 'Delete',
                    onPressed: () {},
                    variant: DSButtonVariant.error,
                    size: DSButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
