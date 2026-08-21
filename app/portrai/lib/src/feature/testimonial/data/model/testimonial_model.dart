import 'package:json_annotation/json_annotation.dart';

part 'testimonial_model.g.dart';

@JsonSerializable()
class TestimonialModel {
  TestimonialModel({
    required this.id,
    required this.name,
    required this.position,
    required this.company,
    required this.testimonial,
    required this.date,
    required this.profileImage,
    required this.companyLogo,
    required this.linkedinProfile,
    required this.projectContext,
    required this.locale,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) =>
      _$TestimonialModelFromJson(json);

  final String id;
  final String name;
  final String position;
  final String company;
  final String testimonial;
  final String date;
  final String profileImage;
  final String companyLogo;
  final String linkedinProfile;
  final String projectContext;
  final String locale;

  Map<String, dynamic> toJson() => _$TestimonialModelToJson(this);
}
