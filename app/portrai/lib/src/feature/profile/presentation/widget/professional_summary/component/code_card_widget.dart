part of '../professional_summary_widget.dart';

/// The developer's profile presented as a macOS-style terminal session.
class _CodeCardWidget extends StatelessWidget {
  const _CodeCardWidget({
    required this.profile,
    required this.stack,
    required this.hasHorizontalPadding,
    required this.isVisible,
  });

  final ProfileEntity profile;
  final List<String> stack;
  final bool hasHorizontalPadding;
  final bool isVisible;

  static const _background = Color(0xFF1E1E1E);
  static const _titleBar = Color(0xFF2D2D2D);
  static const _border = Color(0xFF3F3F3F);

  @override
  Widget build(BuildContext context) {
    final stackLabel = stack.take(3).join(', ');

    final commands = <_TerminalCommand>[
      (
        command: 'whoami',
        output: '${profile.currentRole} @ ${profile.currentCompany}',
      ),
      if (stackLabel.isNotEmpty) (command: 'echo \$STACK', output: stackLabel),
      (
        command: './stats',
        output:
            '${profile.projectsDelivered}+ projects, '
            '${profile.yearsOfExperience}+ years',
      ),
    ];

    return Padding(
      padding: hasHorizontalPadding
          ? context.horizontalScreenPadding
          : EdgeInsets.zero,
      child:
          SizedBox(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    context.dimen.radiusLevel3.value,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _background,
                      border: Border.all(color: _border),
                      borderRadius: BorderRadius.circular(
                        context.dimen.radiusLevel3.value,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _WindowChromeWidget(backgroundColor: _titleBar),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.space(factor: 1.5),
                            vertical: context.space(factor: 0.75),
                          ),
                          child: _TypedTerminalWidget(
                            commands: commands,
                            isTyping: isVisible,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .animate(target: isVisible ? 1 : 0)
              .slideY(
                begin: 0.3,
                duration: 300.ms,
                delay: 150.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(duration: 300.ms, delay: 150.ms),
    );
  }
}

typedef _TerminalCommand = ({String command, String output});

/// A terminal session where each command is typed out character by character
/// and its output is printed right after, followed by a fresh prompt. The full
/// text is laid out invisibly underneath so the card keeps its final size.
class _TypedTerminalWidget extends StatelessWidget {
  const _TypedTerminalWidget({required this.commands, required this.isTyping});

  final List<_TerminalCommand> commands;
  final bool isTyping;

  static const _fontFamily = 'monospace';
  static const _charactersPerSecond = 40;
  static const _prompt = '❯ ';
  static const _promptColor = Color(0xFF28C840);
  static const _commandColor = Color(0xFFF2F2F2);
  static const _outputColor = Color(0xFFB4B4B4);
  static const _cursorColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    final style = context.typography.emphasizedLabelMedium.textStyle.copyWith(
      fontFamily: _fontFamily,
      package: 'design_system',
      color: _outputColor,
      height: 1.4,
    );

    final segments = <({String text, Color color})>[
      for (final (index, entry) in commands.indexed) ...[
        (text: _prompt, color: _promptColor),
        (text: '${entry.command}\n', color: _commandColor),
        (
          text: index == commands.length - 1
              ? entry.output
              : '${entry.output}\n',
          color: _outputColor,
        ),
      ],
    ];
    final total = segments.fold<int>(0, (sum, item) => sum + item.text.length);

    TextSpan spansFor(int typed, {required bool visible}) {
      var remaining = typed;
      final spans = <InlineSpan>[];
      for (final segment in segments) {
        final count = remaining.clamp(0, segment.text.length);
        spans.add(
          TextSpan(
            text: segment.text.substring(0, count),
            style: TextStyle(color: visible ? segment.color : null),
          ),
        );
        remaining -= segment.text.length;
      }
      return TextSpan(children: spans);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isTyping ? total.toDouble() : 0),
      duration: Duration(milliseconds: total * 1000 ~/ _charactersPerSecond),
      builder: (context, progress, _) {
        return Stack(
          children: [
            Opacity(
              opacity: 0,
              child: Text.rich(spansFor(total, visible: false), style: style),
            ),
            Positioned.fill(
              child: Text.rich(
                TextSpan(
                  children: [
                    spansFor(progress.floor(), visible: true),
                    const TextSpan(
                      text: '█',
                      style: TextStyle(color: _cursorColor),
                    ),
                  ],
                ),
                style: style,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The macOS title bar: traffic lights and the session title.
class _WindowChromeWidget extends StatelessWidget {
  const _WindowChromeWidget({required this.backgroundColor});

  final Color backgroundColor;

  static const _trafficLights = [
    Color(0xFFFF5F57),
    Color(0xFFFEBC2E),
    Color(0xFF28C840),
  ];

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.typography.emphasizedLabelMedium.textStyle
        .copyWith(color: const Color(0xFF9A9A9A));

    return Container(
      color: backgroundColor,
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 1.5),
        vertical: context.space(factor: 0.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: context.space(),
              children: [
                for (final color in _trafficLights)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
          Text('portrai — zsh', style: titleStyle),
        ],
      ),
    );
  }
}
