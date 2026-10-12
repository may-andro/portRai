import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/project/domain/entity/project_market_entity.dart';
import 'package:portrai/src/feature/project/domain/entity/project_metric_entity.dart';

class ProjectEntity extends Equatable {
  const ProjectEntity({
    required this.title,
    required this.description,
    required this.longDescription,
    required this.technologies,
    required this.category,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.image,
    required this.appStore,
    required this.playStore,
    required this.website,
    required this.github,
    required this.features,
    required this.achievements,
    required this.teamSize,
    required this.role,
    required this.id,
    this.experienceId,
    this.markets = const [],
    this.metrics = const [],
  });

  final String title;
  final String description;
  final String longDescription;
  final List<String> technologies;
  final String category;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final String image;
  final String? appStore;
  final String? playStore;
  final String? website;
  final String? github;
  final List<String> features;
  final List<String> achievements;
  final int teamSize;
  final String role;
  final String id;

  /// The experience (employer) this project was delivered under.
  final String? experienceId;

  /// Countries where the product is offered; one project can span several.
  final List<ProjectMarketEntity> markets;
  final List<ProjectMetricEntity> metrics;

  @override
  List<Object?> get props => [
    title,
    description,
    longDescription,
    technologies,
    category,
    status,
    startDate,
    endDate,
    image,
    appStore,
    playStore,
    website,
    github,
    features,
    achievements,
    teamSize,
    role,
    id,
    experienceId,
    markets,
    metrics,
  ];
}
