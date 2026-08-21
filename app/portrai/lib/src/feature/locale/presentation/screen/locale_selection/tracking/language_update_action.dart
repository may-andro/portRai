import 'package:json_annotation/json_annotation.dart';
import 'package:tracking/tracking.dart';

part 'language_update_action.g.dart';

@JsonSerializable()
class LanguageUpdateAction extends TrackingAction {
  const LanguageUpdateAction({
    required this.previousLanguage,
    required this.newLanguage,
  }) : super('language_update');

  @JsonKey(name: 'previous_language')
  final String previousLanguage;

  @JsonKey(name: 'new_language')
  final String newLanguage;

  @override
  Map<String, dynamic> toJson() => _$LanguageUpdateActionToJson(this);
}
