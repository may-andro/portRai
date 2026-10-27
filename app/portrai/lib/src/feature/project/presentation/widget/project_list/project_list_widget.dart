import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

class ProjectListWidget extends StatelessWidget {
  const ProjectListWidget({
    super.key,
    required this.projects,
    required this.isVisible,
    required this.onClicked,
  });

  final List<ProjectEntity> projects;
  final bool isVisible;

  /// Called with the project that is tapped. The caller decides what the tap
  /// does, such as opening the project.
  final ValueChanged<ProjectEntity> onClicked;

  @override
  Widget build(BuildContext context) {
    // Room for the hover scale/glow, which the section would otherwise clip.
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(),
        vertical: context.space(factor: 2),
      ),
      child: DSStaggeredGridWidget(
        crossAxisCount: context.crossAxisCount,
        itemCount: projects.length,
        crossAxisSpacing: context.space(),
        mainAxisSpacing: context.space(),
        itemBuilder: (_, index) {
          return _ProjectWidget(project: projects[index], onClicked: onClicked)
              .animate(target: isVisible ? 1 : 0)
              .scale(
                begin: const Offset(0.6, 0.6),
                end: const Offset(1, 1),
                duration: 450.ms,
                delay: (80 + index * 70).ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(delay: (80 + index * 70).ms, duration: 300.ms);
        },
      ),
    );
  }
}

class _ProjectWidget extends StatefulWidget {
  const _ProjectWidget({required this.project, required this.onClicked});

  final ProjectEntity project;
  final ValueChanged<ProjectEntity> onClicked;

  @override
  State<_ProjectWidget> createState() => _ProjectWidgetState();
}

class _ProjectWidgetState extends State<_ProjectWidget> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final palette = context.colorPalette;
    final accent = palette.brand.primary.color;
    const base = Color(0xFF0E1726);
    final start = Color.lerp(base, accent, 0.22)!;
    final end = Color.lerp(base, palette.brand.tertiary.color, 0.2)!;
    final radius = BorderRadius.circular(context.dimen.radiusLevel2.value);

    return Tooltip(
      message: project.title,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () => widget.onClicked(project),
          child: AnimatedScale(
            scale: _hover ? 1.08 : 1,
            duration: 250.ms,
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: 250.ms,
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [start, end],
                ),
                border: Border.all(
                  color: _hover ? accent : Colors.white.withAlpha(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withAlpha(_hover ? 110 : 25),
                    blurRadius: _hover ? 22 : 8,
                    offset: Offset(0, _hover ? 8 : 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(context.space(factor: 0.75)),
                      child: Hero(
                        tag: 'project-image-${project.id}',
                        child: DSNetworkImageWidget(
                          url: project.image,
                          autoSizeImage: true,
                          fit: BoxFit.contain,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(
                            context.dimen.radiusLevel1.value,
                          ),
                        ),
                      ),
                    ),
                    if (project.title.trailingEmoji case final String emoji)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.space(factor: 0.5),
                            vertical: context.space(factor: 0.25),
                          ),
                          decoration: BoxDecoration(
                            color: base.withAlpha(220),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                            ),
                          ),
                          child: DSTextWidget(
                            emoji,
                            style: context.typography.emphasizedLabelSmall,
                            color: palette.neutral.grey10,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on String {
  /// Returns the trailing emoji if present, otherwise `null`.
  String? get trailingEmoji {
    final emojiRegex = RegExp(
      r'((?:\uD83C[\uDDE6-\uDDFF]){2}|[\uD83D\uD83C\uD83E][\uDC00-\uDFFF]|[\u2600-\u27BF])$',
    );
    final match = emojiRegex.firstMatch(trimRight());
    return match?.group(0);
  }
}

extension on BuildContext {
  int get crossAxisCount {
    switch (deviceWidth) {
      case DSDeviceWidthResolution.xs:
        return 5;
      case DSDeviceWidthResolution.s:
        return 7;
      case DSDeviceWidthResolution.m:
        return 8;
      case DSDeviceWidthResolution.l:
        return 9;
      case DSDeviceWidthResolution.xl:
        return 10;
    }
  }
}
