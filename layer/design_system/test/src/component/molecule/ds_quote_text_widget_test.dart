import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSQuoteTextWidget',
    (theme) => [
      const TestCase(
        'short quote',
        SizedBox(
          width: 300,
          child: DSQuoteTextWidget(
            text: 'A great team makes great products.',
            maxLines: 3,
          ),
        ),
      ),
      const TestCase(
        'long quote truncated',
        SizedBox(
          width: 300,
          child: DSQuoteTextWidget(
            text:
                'Working with this team was an absolute pleasure. '
                'Their attention to detail and commitment to quality '
                'exceeded all expectations.',
            maxLines: 3,
          ),
        ),
      ),
    ],
  );
}
