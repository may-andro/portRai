import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';
import 'package:portrai/src/feature/project/presentation/screen/_screen.dart';

class ProjectListWidget extends StatelessWidget {
  const ProjectListWidget({
    super.key,
    required this.projects,
    required this.isVisible,
  });

  final List<ProjectEntity> projects;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return DSStaggeredGridWidget(
      crossAxisCount: context.crossAxisCount,
      itemCount: projects.length,
      crossAxisSpacing: context.space(),
      mainAxisSpacing: context.space(),
      itemBuilder: (_, index) {
        return _ProjectWidget(project: projects[index])
            .animate(target: isVisible ? 1 : 0)
            .slideY(
              begin: 1 + (index * 0.2),
              duration: 300.ms,
              delay: (100 + index * 100).ms,
              curve: Curves.easeOut,
            )
            .fadeIn(delay: (300 + index * 100).ms, duration: 300.ms);
      },
    );
  }
}

class _ProjectWidget extends StatelessWidget {
  const _ProjectWidget({required this.project});

  final ProjectEntity project;

  @override
  Widget build(BuildContext context) {
    final cardColor = context.colorPalette.surface.inverseSurface;
    final cardRadius = context.dimen.radiusLevel1;
    return DSHoverableContainerWidget(
      builder: (BuildContext context, bool isHovering) {
        return DSCardWidget(
          onTap: () {
            ProjectScreen.navigate(context, project: project);
          },
          backgroundColor: cardColor,
          shadowColor: cardColor,
          elevation: isHovering
              ? context.dimen.elevationLevel3
              : context.dimen.elevationLevel1,
          radius: cardRadius,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(context.space()),
                child: Hero(
                  tag: 'project-image-${project.title}',
                  child: DSNetworkImageWidget(
                    url: project.image,
                    autoSizeImage: true,
                    fit: BoxFit.contain,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(cardRadius.value),
                  ),
                ),
              ),
              if (project.title.trailingEmoji case final String emoji) ...[
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: DSCardWidget(
                    backgroundColor: cardColor,
                    elevation: context.dimen.elevationNone,
                    radius: cardRadius,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.space(factor: 0.5),
                        vertical: context.space(factor: 0.25),
                      ),
                      child: DSTextWidget(
                        emoji,
                        style: context.typography.emphasizedLabelSmall,
                        color: context.colorPalette.neutral.grey10,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
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
