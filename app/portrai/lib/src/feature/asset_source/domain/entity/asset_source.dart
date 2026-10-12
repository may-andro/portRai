enum AssetSource {
  real,
  template;

  bool get isTemplate => this == AssetSource.template;

  String assetPath(String name) {
    final suffix = isTemplate ? '.template' : '';
    return 'assets/dashboard/$name$suffix.json';
  }
}
