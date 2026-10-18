import 'package:equatable/equatable.dart';

/// Where a project link leads to; picks the icon shown in the PDF.
enum CvProjectLinkType { web, ios, android }

/// A clickable destination of a project, such as a store listing.
class CvProjectLinkEntity extends Equatable {
  const CvProjectLinkEntity({required this.type, required this.url});

  final CvProjectLinkType type;
  final String url;

  @override
  List<Object?> get props => [type, url];
}
