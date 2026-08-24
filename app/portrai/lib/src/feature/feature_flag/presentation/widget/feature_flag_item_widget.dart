import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';
import 'package:portrai/src/feature/feature_flag/presentation/bloc/_bloc.dart';

class FeatureFlagItemWidget extends StatelessWidget {
  const FeatureFlagItemWidget({super.key, required this.flag});

  final AppFeatureFlagEntity flag;

  @override
  Widget build(BuildContext context) {
    final isEnabled = flag.isEnabled;

    return Padding(
      padding: EdgeInsets.only(bottom: context.space()),
      child: DSCardWidget(
        onTap: () {
          context.bloc.add(ToggleFeatureFlagEvent(flag));
        },
        backgroundColor: isEnabled
            ? context.colorPalette.success
            : context.colorPalette.surface.surface,
        backgroundColorOpacity: isEnabled ? 0.1 : 1.0,
        radius: const DSRadius(8),
        elevation: const DSElevation(0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEnabled
                  ? context.colorPalette.success.color
                  : context.colorPalette.neutral.grey3.color,
              width: isEnabled ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(context.space(factor: 1.5)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DSTextWidget(
                              flag.name,
                              style: context.typography.titleMedium,
                              color: isEnabled
                                  ? context.colorPalette.success
                                  : context.colorPalette.onBackground,
                            ),
                          ),
                          if (flag.isOverridden) ...[
                            const DSHorizontalSpacerWidget(1),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color:
                                    context.colorPalette.semantic.warning.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (flag.description != null) ...[
                        const DSVerticalSpacerWidget(0.5),
                        DSTextWidget(
                          flag.description!,
                          style: context.typography.bodySmall,
                          color: context.colorPalette.neutral.grey6,
                        ),
                      ],
                      const DSVerticalSpacerWidget(0.5),
                      DSTextWidget(
                        flag.statusDescription,
                        style: context.typography.labelSmall,
                        color: isEnabled
                            ? context.colorPalette.semantic.success
                            : context.colorPalette.neutral.grey5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
