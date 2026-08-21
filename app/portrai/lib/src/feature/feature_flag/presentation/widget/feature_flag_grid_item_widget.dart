import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';
import 'package:portrai/src/feature/feature_flag/presentation/bloc/_bloc.dart';

class FeatureFlagGridItemWidget extends StatelessWidget {
  const FeatureFlagGridItemWidget({super.key, required this.flag});

  final AppFeatureFlagEntity flag;

  @override
  Widget build(BuildContext context) {
    final isEnabled = flag.isEnabled;

    return DSCardWidget(
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
          child: Stack(
            children: [
              Center(
                child: DSTextWidget(
                  flag.name,
                  style: context.typography.labelMedium,
                  color: isEnabled
                      ? context.colorPalette.success
                      : context.colorPalette.onBackground,
                  maxLines: 3,
                  textOverflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (flag.isOverridden)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.colorPalette.semantic.warning.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
