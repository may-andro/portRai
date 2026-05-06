import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSLabeledInfoRowWidget',
    (theme) => [
      const TestCase(
        'without tap',
        SizedBox(
          width: 300,
          child: DSLabeledInfoRowWidget(
            icon: Icons.email_outlined,
            label: 'Email',
            value: 'hello@example.com',
          ),
        ),
      ),
      TestCase(
        'with tap (chevron)',
        SizedBox(
          width: 300,
          child: DSLabeledInfoRowWidget(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: '+1 234 567 890',
            onTap: () {},
          ),
        ),
      ),
    ],
  );
}
