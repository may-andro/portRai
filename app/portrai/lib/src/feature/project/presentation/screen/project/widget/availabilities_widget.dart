import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/_bloc.dart';

class AvailabilitiesWidget extends StatelessWidget {
  const AvailabilitiesWidget({super.key, required this.project});

  final ProjectEntity project;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    if (project.github case final String github) {
      buttons.add(
        _ButtonWidget(label: 'GitHub', icon: Icons.code, url: github),
      );
    }
    if (project.website case final String website) {
      buttons.add(
        _ButtonWidget(label: 'Website', icon: Icons.language, url: website),
      );
    }
    if (project.appStore case final String appStore) {
      buttons.add(
        _ButtonWidget(label: 'App Store', icon: Icons.apple, url: appStore),
      );
    }
    if (project.playStore case final String playStore) {
      buttons.add(
        _ButtonWidget(label: 'Play Store', icon: Icons.shop, url: playStore),
      );
    }

    return Wrap(
      spacing: context.space(),
      runSpacing: context.space(),
      children: buttons,
    );
  }
}

class _ButtonWidget extends StatelessWidget {
  const _ButtonWidget({
    required this.label,
    required this.icon,
    required this.url,
  });

  final String label;
  final IconData icon;
  final String url;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: DSButtonWidget(
        label: label,
        icon: icon,
        variant: DSButtonVariant.secondary,
        onPressed: () {
          context.bloc.add(OpenExternalUrlEvent(url: url, label: label));
        },
        border: DSButtonBorder.rounded,
        size: DSButtonSize.small,
      ),
    );
  }
}
