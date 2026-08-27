/// Compares dot-separated numeric version strings, e.g. `"1.2.3"`.
///
/// Missing segments are treated as `0` (so `"1.2"` == `"1.2.0"`), and any
/// non-numeric suffix on a segment (e.g. a `"-beta"` tag) is ignored.
extension VersionComparisonExtension on String {
  /// Returns a negative number if this version is lower than [other], zero
  /// if they are equal, or a positive number if this version is higher.
  int compareVersion(String other) {
    final thisParts = _versionParts;
    final otherParts = other._versionParts;
    final maxLength = thisParts.length > otherParts.length
        ? thisParts.length
        : otherParts.length;

    for (var i = 0; i < maxLength; i++) {
      final thisPart = i < thisParts.length ? thisParts[i] : 0;
      final otherPart = i < otherParts.length ? otherParts[i] : 0;
      final comparison = thisPart.compareTo(otherPart);
      if (comparison != 0) return comparison;
    }

    return 0;
  }

  /// Whether this version is strictly lower than [other].
  bool isLowerVersionThan(String other) => compareVersion(other) < 0;

  List<int> get _versionParts => split('.').map((part) {
    final numericPrefix = RegExp(r'^\d+').stringMatch(part);
    return int.tryParse(numericPrefix ?? '') ?? 0;
  }).toList();
}
