import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';

class SetupProgressWidget extends StatelessWidget {
  const SetupProgressWidget(this.progress, {super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.localizations.splashProdMessage,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.15,
            height: 24 / 16,
            color: context.color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(value: progress, color: Colors.green),
        const SizedBox(height: 48),
      ],
    );
  }
}

extension on BuildContext {
  Color get color {
    return MediaQuery.of(this).platformBrightness == Brightness.light
        ? const Color(0xFF121212)
        : const Color(0xFFFFFFFF);
  }
}
