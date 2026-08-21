import 'package:equatable/equatable.dart';

class CoordinatesEntity extends Equatable {
  const CoordinatesEntity({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}
