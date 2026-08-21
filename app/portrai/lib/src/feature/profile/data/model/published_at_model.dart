import 'package:json_annotation/json_annotation.dart';

part 'published_at_model.g.dart';

@JsonSerializable()
class PublishedAtModel {
  PublishedAtModel({
    required this.name,
    required this.url,
    required this.image,
  });

  factory PublishedAtModel.fromJson(Map<String, dynamic> json) =>
      _$PublishedAtModelFromJson(json);

  final String name;
  final String url;
  final String image;

  Map<String, dynamic> toJson() => _$PublishedAtModelToJson(this);
}
