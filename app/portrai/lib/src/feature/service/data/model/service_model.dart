import 'package:json_annotation/json_annotation.dart';
import 'package:portrai/src/feature/service/data/model/service_faq_model.dart';

part 'service_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ServiceModel {
  ServiceModel({
    required this.title,
    required this.description,
    required this.image,
    required this.detail,
    required this.locale,
    this.id,
    this.deliverables = const [],
    this.technologies = const [],
    this.projectIds = const [],
    this.engagementTypes = const [],
    this.idealFor = const [],
    this.process = const [],
    this.faq = const [],
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceModelFromJson(json);

  final String title;
  final String description;
  final String image;
  final String detail;
  final String locale;
  final String? id;
  final List<String> deliverables;
  final List<String> technologies;
  final List<String> projectIds;
  final List<String> engagementTypes;
  final List<String> idealFor;
  final List<String> process;
  final List<ServiceFaqModel> faq;

  Map<String, dynamic> toJson() => _$ServiceModelToJson(this);
}
