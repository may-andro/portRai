import 'package:json_annotation/json_annotation.dart';

part 'social_link_model.g.dart';

@JsonSerializable()
class SocialLinkModel {
  SocialLinkModel({required this.name, required this.url, required this.image});

  factory SocialLinkModel.fromJson(Map<String, dynamic> json) =>
      _$SocialLinkModelFromJson(json);

  final String name;
  final String url;
  final String image;

  Map<String, dynamic> toJson() => _$SocialLinkModelToJson(this);
}
