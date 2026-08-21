extension LocaleCodeExtension on String {
  String get languageName {
    switch (this) {
      case 'en':
        return '🇬🇧 English';
      case 'nl':
        return '🇳🇱 Dutch';
      case 'es':
        return '🇪🇸 Spanish';
      default:
        return 'Unknown Language';
    }
  }
}
