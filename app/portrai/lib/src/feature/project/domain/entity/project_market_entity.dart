import 'package:equatable/equatable.dart';

/// A country where the product is offered, not where the work was done.
class ProjectMarketEntity extends Equatable {
  const ProjectMarketEntity({
    required this.country,
    required this.latitude,
    required this.longitude,
    this.appStore,
    this.playStore,
    this.website,
  });

  final String country;
  final double latitude;
  final double longitude;
  final String? appStore;
  final String? playStore;
  final String? website;

  @override
  List<Object?> get props => [
    country,
    latitude,
    longitude,
    appStore,
    playStore,
    website,
  ];
}
