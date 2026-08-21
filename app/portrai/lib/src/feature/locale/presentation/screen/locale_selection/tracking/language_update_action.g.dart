// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_update_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanguageUpdateAction _$LanguageUpdateActionFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'LanguageUpdateAction',
  json,
  ($checkedConvert) {
    final val = LanguageUpdateAction(
      previousLanguage: $checkedConvert(
        'previous_language',
        (v) => v as String,
      ),
      newLanguage: $checkedConvert('new_language', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'previousLanguage': 'previous_language',
    'newLanguage': 'new_language',
  },
);

Map<String, dynamic> _$LanguageUpdateActionToJson(
  LanguageUpdateAction instance,
) => <String, dynamic>{
  'previous_language': instance.previousLanguage,
  'new_language': instance.newLanguage,
};
