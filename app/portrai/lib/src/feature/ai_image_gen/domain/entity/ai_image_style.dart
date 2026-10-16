import 'package:portrai/src/feature/ai_image_gen/domain/entity/ai_image_prompts.dart';

enum AiImageStyle {
  avatar('Anime avatar', AiImagePrompts.avatar),
  attackOnTitan('Attack on Titan', AiImagePrompts.attackOnTitan),
  naruto('Naruto', AiImagePrompts.naruto),
  manga('Manga', AiImagePrompts.manga);

  const AiImageStyle(this.label, this.prompt);

  final String label;
  final String prompt;
}
