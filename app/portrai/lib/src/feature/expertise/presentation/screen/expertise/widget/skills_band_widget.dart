part of 'content_widget.dart';

class _SkillsBandWidget extends StatelessWidget {
  const _SkillsBandWidget({required this.expertise});

  final ExpertiseEntity expertise;

  @override
  Widget build(BuildContext context) {
    return _BandWidget(
      color: context.colorPalette.background.color,
      background: _ImageAccentsWidget(imageUrl: expertise.image),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.space(factor: 3),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _EyebrowWidget(context.localizations.expertiseSkillsHeading),
          ),
          Column(
            children: [
              for (final (index, skill) in expertise.skills.indexed)
                _RevealWidget(
                  child: _SkillSectionWidget(skill: skill, index: index),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
