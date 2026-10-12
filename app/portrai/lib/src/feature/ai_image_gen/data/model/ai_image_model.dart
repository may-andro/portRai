import 'dart:typed_data';

class AiImageModel {
  const AiImageModel({
    required this.key,
    required this.mimeType,
    required this.bytes,
  });

  final String key;
  final String mimeType;
  final Uint8List bytes;

  @override
  String toString() =>
      'AiImageModel(key: $key, mimeType: $mimeType, bytes: ${bytes.length})';
}
