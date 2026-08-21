import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/profile/domain/entity/coordinates_entity.dart';

class LocationEntity extends Equatable {
  const LocationEntity({
    required this.city,
    required this.state,
    required this.country,
    required this.timezone,
    required this.coordinates,
  });

  final String city;
  final String state;
  final String country;
  final String timezone;
  final CoordinatesEntity coordinates;

  @override
  List<Object?> get props => [city, state, country, timezone, coordinates];
}
