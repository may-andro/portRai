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
    final l10n = context.localizations;
    final buttons = [
      ..._buttons(
        label: l10n.projectGitHub,
        icon: Icons.code,
        links: _links((market) => market.github),
      ),
      ..._buttons(
        label: l10n.projectWebsite,
        icon: Icons.language,
        links: _links((market) => market.website),
      ),
      ..._buttons(
        label: l10n.projectAppStore,
        icon: Icons.apple,
        links: _links((market) => market.appStore),
      ),
      ..._buttons(
        label: l10n.projectPlayStore,
        icon: Icons.shop,
        links: _links((market) => market.playStore),
      ),
    ];

    return Wrap(
      spacing: context.space(),
      runSpacing: context.space(),
      children: buttons,
    );
  }

  /// Maps each distinct URL to the countries it is offered in, so markets
  /// sharing one link produce a single entry.
  Map<String, List<String>> _links(String? Function(ProjectMarketEntity) get) {
    final links = <String, List<String>>{};
    for (final market in project.markets) {
      final url = get(market);
      if (url == null) continue;
      links.putIfAbsent(url, () => []).add(market.country);
    }
    return links;
  }

  /// Country is only added to the label when a store has several distinct links.
  Iterable<Widget> _buttons({
    required String label,
    required IconData icon,
    required Map<String, List<String>> links,
  }) {
    return links.entries.map((entry) {
      final text = links.length == 1
          ? label
          : '$label · ${entry.value.join(', ')}';
      return _ButtonWidget(label: text, icon: icon, url: entry.key);
    });
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
