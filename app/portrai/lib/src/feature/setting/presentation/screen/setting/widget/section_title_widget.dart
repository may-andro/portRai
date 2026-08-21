import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class SectionTitleWidget extends StatelessWidget {
  const SectionTitleWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.space()),
        child: DSTextWidget(
          title,
          style: context.typography.titleMedium,
          color: context.colorPalette.neutral.grey9,
        ),
      ),
    );
  }
}
