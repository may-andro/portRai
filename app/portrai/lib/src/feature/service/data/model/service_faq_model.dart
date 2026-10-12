import 'package:json_annotation/json_annotation.dart';

part 'service_faq_model.g.dart';

@JsonSerializable()
class ServiceFaqModel {
  ServiceFaqModel({required this.question, required this.answer});

  factory ServiceFaqModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceFaqModelFromJson(json);

  final String question;
  final String answer;

  Map<String, dynamic> toJson() => _$ServiceFaqModelToJson(this);
}
