import 'package:equatable/equatable.dart';

/// A country the profile owner has shipped work to, taken from project markets.
class WorkPlaceEntity extends Equatable {
  const WorkPlaceEntity({
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  final String country;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [country, latitude, longitude];
}
