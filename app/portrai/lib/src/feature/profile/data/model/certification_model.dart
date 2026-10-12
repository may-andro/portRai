import 'package:json_annotation/json_annotation.dart';

part 'certification_model.g.dart';

@JsonSerializable()
class CertificationModel {
  const CertificationModel({
    required this.name,
    required this.issuer,
    required this.date,
    this.url,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) =>
      _$CertificationModelFromJson(json);

  final String name;
  final String issuer;
  final String date;
  final String? url;

  Map<String, dynamic> toJson() => _$CertificationModelToJson(this);
}
