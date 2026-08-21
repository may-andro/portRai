import 'package:json_annotation/json_annotation.dart';

part 'resume_model.g.dart';

@JsonSerializable()
class ResumeModel {
  ResumeModel({
    required this.url,
    required this.lastUpdated,
    required this.image,
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) =>
      _$ResumeModelFromJson(json);

  final String url;
  final String lastUpdated;
  final String image;

  Map<String, dynamic> toJson() => _$ResumeModelToJson(this);
}
