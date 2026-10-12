import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/service/domain/entity/service_faq_entity.dart';

class ServiceEntity extends Equatable {
  const ServiceEntity({
    required this.image,
    required this.title,
    required this.description,
    required this.detail,
    this.id,
    this.deliverables = const [],
    this.technologies = const [],
    this.projectIds = const [],
    this.engagementTypes = const [],
    this.idealFor = const [],
    this.process = const [],
    this.faq = const [],
  });

  final String image;
  final String title;
  final String description;
  final String detail;
  final String? id;

  /// What the client receives.
  final List<String> deliverables;
  final List<String> technologies;

  /// Projects that show this service in practice.
  final List<String> projectIds;
  final List<String> engagementTypes;
  final List<String> idealFor;

  /// Ordered steps of how the work is done.
  final List<String> process;
  final List<ServiceFaqEntity> faq;

  @override
  List<Object?> get props => [
    image,
    title,
    description,
    detail,
    id,
    deliverables,
    technologies,
    projectIds,
    engagementTypes,
    idealFor,
    process,
    faq,
  ];
}
