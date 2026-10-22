final _nonDialableCharacters = RegExp(r'[^0-9+]');

/// `mailto:` and `tel:` links for the profile email and phone in the decoded
/// portfolio context, the only contact links the model may offer besides
/// HTTPS URLs.
Set<String> assistantContactLinksFrom(Object? portfolio) {
  final profile = portfolio is Map ? portfolio['profile'] : null;
  if (profile is! Map) return const {};
  final email = profile['email'];
  final phone = profile['phone'];
  final dialable = phone is String
      ? phone.replaceAll(_nonDialableCharacters, '')
      : '';
  return {
    if (email is String && email.trim().isNotEmpty) 'mailto:${email.trim()}',
    if (dialable.isNotEmpty) 'tel:$dialable',
  };
}
