import 'dart:convert';

/// `mailto:` and `tel:` links for the profile email and phone in the portfolio
/// context, the only contact links the model may offer besides HTTPS URLs.
Set<String> assistantContactLinksFrom(String portfolioContext) {
  try {
    final root = jsonDecode(portfolioContext);
    final profile = root is Map ? root['profile'] : null;
    if (profile is! Map) return const {};
    final email = profile['email'];
    final phone = profile['phone'];
    final dialable = phone is String
        ? phone.replaceAll(RegExp(r'[^0-9+]'), '')
        : '';
    return {
      if (email is String && email.trim().isNotEmpty) 'mailto:${email.trim()}',
      if (dialable.isNotEmpty) 'tel:$dialable',
    };
  } on FormatException {
    return const {};
  }
}
