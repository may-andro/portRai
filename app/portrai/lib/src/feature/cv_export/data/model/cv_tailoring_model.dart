import 'package:json_annotation/json_annotation.dart';

part 'cv_tailoring_model.g.dart';

/// The JSON response of a tailoring request.
@JsonSerializable(createToJson: false)
class CvTailoringModel {
  CvTailoringModel({
    required this.summary,
    this.projectOrder = const [],
    this.skillGroupOrder = const [],
    this.prioritizedSkills = const [],
  });

  factory CvTailoringModel.fromJson(Map<String, dynamic> json) =>
      _$CvTailoringModelFromJson(json);

  final String summary;
  final List<int> projectOrder;
  final List<int> skillGroupOrder;
  final List<String> prioritizedSkills;
}
