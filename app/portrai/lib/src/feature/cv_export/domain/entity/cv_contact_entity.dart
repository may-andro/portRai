import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_contact_type.dart';

class CvContactEntity extends Equatable {
  const CvContactEntity({
    required this.text,
    this.url,
    this.type = CvContactType.website,
  });

  final String text;

  /// Makes the contact clickable in the PDF when present.
  final String? url;
  final CvContactType type;

  @override
  List<Object?> get props => [text, url, type];
}
