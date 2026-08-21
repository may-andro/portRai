import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class EmptySearchResultWidget extends StatelessWidget {
  const EmptySearchResultWidget({super.key, required this.searchQuery});

  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.space(factor: 4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DSIconWidget(
              Icons.search_off,
              color: context.colorPalette.neutral.grey7,
              size: DSIconSize.large,
            ),
            const DSVerticalSpacerWidget(2),
            DSTextWidget(
              'No results found',
              style: context.typography.titleMedium,
              color: context.colorPalette.onBackground,
            ),
            const DSVerticalSpacerWidget(1),
            DSTextWidget(
              'No feature flags match "$searchQuery"',
              style: context.typography.bodyMedium,
              color: context.colorPalette.neutral.grey7,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
