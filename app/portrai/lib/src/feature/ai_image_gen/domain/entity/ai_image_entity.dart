import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class AiImageEntity extends Equatable {
  const AiImageEntity({required this.bytes, required this.mimeType});

  final Uint8List bytes;
  final String mimeType;

  @override
  List<Object> get props => [bytes, mimeType];

  // Use cases log their params; printing every byte would flood the console.
  @override
  String toString() =>
      'AiImageEntity(mimeType: $mimeType, bytes: ${bytes.length})';
}
