import 'package:equatable/equatable.dart';

class CvProjectEntity extends Equatable {
  const CvProjectEntity({
    required this.title,
    required this.role,
    required this.description,
    required this.technologies,
    this.url,
  });

  final String title;
  final String role;
  final String description;
  final List<String> technologies;

  /// Makes the project clickable in the PDF when present.
  final String? url;

  @override
  List<Object?> get props => [title, role, description, technologies, url];
}
