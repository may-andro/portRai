part of 'content_widget.dart';

extension on ProfileEntity {
  /// Extra photos shown around the main portrait, never the portrait itself.
  List<String> get backdropImages {
    final others = profileImages
        .where((url) => url.isNotEmpty && url != profileImage)
        .toSet()
        .toList();
    if (others.isEmpty && coverImage.isNotEmpty) return [coverImage];
    return others.take(3).toList();
  }
}
