import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:module_injector/module_injector.dart';

/// Downloads the profile photo embedded in the CV.
@register
class CvPhotoLoader {
  static const Duration _timeout = Duration(seconds: 8);

  /// Returns the photo bytes, or `null` when the photo cannot be fetched
  /// (offline, blocked by CORS on web, missing). The CV is then rendered
  /// without a photo.
  Future<Uint8List?> load(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return null;
    try {
      final response = await http.get(uri).timeout(_timeout);
      return response.statusCode == 200 ? response.bodyBytes : null;
    } on Exception {
      return null;
    }
  }
}
