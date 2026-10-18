import 'package:equatable/equatable.dart';

/// A clickable destination of a project, such as a store listing.
class CvProjectLinkEntity extends Equatable {
  const CvProjectLinkEntity({required this.label, required this.url});

  final String label;
  final String url;

  @override
  List<Object?> get props => [label, url];
}
