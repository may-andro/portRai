import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/_bloc.dart';

class AvailabilitiesWidget extends StatelessWidget {
  const AvailabilitiesWidget({super.key, required this.project});

  final ProjectEntity project;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    for (final market in project.markets) {
      _addStoreButtons(
        context,
        buttons,
        website: market.website,
        appStore: market.appStore,
        playStore: market.playStore,
        github: market.github,
        country: market.country,
      );
    }

    return Wrap(
      spacing: context.space(),
      runSpacing: context.space(),
      children: buttons,
    );
  }
}

void _addStoreButtons(
  BuildContext context,
  List<Widget> buttons, {
  required String? website,
  required String? appStore,
  required String? playStore,
  required String? github,
  String? country,
}) {
  String label(String text) => country == null ? text : '$text · $country';

  if (github != null) {
    buttons.add(
      _ButtonWidget(
        label: label(context.localizations.projectGitHub),
        icon: Icons.code,
        url: github,
      ),
    );
  }
  if (website != null) {
    buttons.add(
      _ButtonWidget(
        label: label(context.localizations.projectWebsite),
        icon: Icons.language,
        url: website,
      ),
    );
  }
  if (appStore != null) {
    buttons.add(
      _ButtonWidget(
        label: label(context.localizations.projectAppStore),
        icon: Icons.apple,
        url: appStore,
      ),
    );
  }
  if (playStore != null) {
    buttons.add(
      _ButtonWidget(
        label: label(context.localizations.projectPlayStore),
        icon: Icons.shop,
        url: playStore,
      ),
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
