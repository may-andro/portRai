import 'package:core/core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';

class SetupFailureWidget extends StatelessWidget {
  const SetupFailureWidget(
    this._cause, {
    this.isDescriptiveMode = false,
    super.key,
  });

  final Object? _cause;
  final bool isDescriptiveMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.localizations.splashErrorTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.15,
              height: 24 / 16,
              color: context.color,
            ),
            textAlign: TextAlign.start,
          ),
          if (isDescriptiveMode) ...[
            const SizedBox(height: 16),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.color),
                  color: context.color.withValues(alpha: 0.5),
                ),
                child: Text(
                  _cause.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.15,
                    height: 24 / 16,
                    color: context.color,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              text: context.localizations.splashErrorMessage,
              style: TextStyle(
                color: context.color,
                fontSize: 14,
                letterSpacing: 0.15,
                height: 20 / 14,
              ),
              children: <TextSpan>[
                const TextSpan(text: ' '),
                TextSpan(
                  text: context.localizations.splashContactSupport,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.15,
                    height: 20 / 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'This feature is not yer developed',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.15,
                              height: 20 / 14,
                              color: context.color,
                            ),
                          ),
                          duration: 300.milliseconds,
                        ),
                      );
                    },
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
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
