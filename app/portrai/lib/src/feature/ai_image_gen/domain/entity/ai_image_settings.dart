import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/entity/ai_image_model_type.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/entity/ai_image_style.dart';

class AiImageSettings extends Equatable {
  const AiImageSettings({
    this.style = AiImageStyle.avatar,
    this.model = AiImageModelType.geminiFlashImage,
  });

  final AiImageStyle style;
  final AiImageModelType model;

  AiImageSettings copyWith({AiImageStyle? style, AiImageModelType? model}) =>
      AiImageSettings(style: style ?? this.style, model: model ?? this.model);

  @override
  List<Object> get props => [style, model];
}
