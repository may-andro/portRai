import 'package:equatable/equatable.dart';

class ResumeEntity extends Equatable {
  const ResumeEntity({
    required this.url,
    required this.lastUpdated,
    required this.image,
  });

  final String url;
  final String lastUpdated;
  final String image;

  @override
  List<Object?> get props => [url, lastUpdated, image];
}
