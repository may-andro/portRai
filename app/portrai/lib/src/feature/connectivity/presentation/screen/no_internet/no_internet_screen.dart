import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';

/// Shown by the splash when the app is opened without internet. Runs before
/// the service locator is ready, so it has no DI dependencies.
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({required this.onRetryClick, super.key});

  final VoidCallback onRetryClick;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 64),
                const SizedBox(height: 24),
                Text(
                  localizations.noInternetScreenTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.noInternetScreenMessage,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: onRetryClick,
                  child: Text(localizations.noInternetScreenRetryButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
