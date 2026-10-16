import 'package:equatable/equatable.dart';

/// Remotely managed overrides for AI image generation; null means default.
class AiImageAppConfig extends Equatable {
  const AiImageAppConfig({this.model, this.style});

  final String? model;

  /// Name of the style (e.g. `avatar`, `naruto`); the app maps it to a prompt.
  final String? style;

  @override
  List<Object?> get props => [model, style];
}
