import 'package:equatable/equatable.dart';

class ServiceEntity extends Equatable {
  const ServiceEntity({
    required this.image,
    required this.title,
    required this.description,
    required this.detail,
  });

  final String image;
  final String title;
  final String description;
  final String detail;

  @override
  List<Object?> get props => [image, title, description, detail];
}
