import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';

class NoInternetBannerWidget extends StatelessWidget {
  const NoInternetBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorPalette.semantic.error.color,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.space(factor: 2),
            vertical: context.space(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DSIconWidget(
                Icons.wifi_off_rounded,
                color: context.colorPalette.semantic.onError,
                size: DSIconSize.small,
              ),
              const DSHorizontalSpacerWidget(1),
              Flexible(
                child: DSTextWidget(
                  context.localizations.noInternetBannerMessage,
                  style: context.typography.bodyMedium,
                  color: context.colorPalette.semantic.onError,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
