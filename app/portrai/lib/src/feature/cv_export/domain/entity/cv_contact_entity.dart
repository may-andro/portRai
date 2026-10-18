import 'package:equatable/equatable.dart';

class CvContactEntity extends Equatable {
  const CvContactEntity({required this.text, this.url});

  final String text;

  /// Makes the contact clickable in the PDF when present.
  final String? url;

  @override
  List<Object?> get props => [text, url];
}
