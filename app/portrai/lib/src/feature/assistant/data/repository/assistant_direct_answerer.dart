import 'dart:convert';

/// Answers contact questions straight from the portfolio JSON built by
/// `GetAssistantContextUseCase`; every other question, including career ones,
/// is left to the on-device model. Returns null when the model is needed.
class AssistantDirectAnswerer {
  AssistantDirectAnswerer(String portfolioContext)
    : _portfolio = _decode(portfolioContext);

  final Map<String, dynamic> _portfolio;

  String? answer(String question) => _contactAnswer(question.toLowerCase());

  String? _contactAnswer(String q) {
    final profile = _portfolio['profile'];
    if (profile is! Map<String, dynamic>) return null;
    final name = profile['name'];
    final email = profile['email'];
    final phone = profile['phone'];
    if (q.contains('email') || q.contains('e-mail')) {
      return "$name's email is $email.";
    }
    if (q.contains('phone') || q.contains('number')) {
      return "$name's phone number is $phone.";
    }
    if (q.contains('contact') || q.contains('reach')) {
      return 'You can contact $name by email at $email or by phone at $phone.';
    }
    return null;
  }

  static Map<String, dynamic> _decode(String source) {
    try {
      final decoded = jsonDecode(source);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      return const {};
    }
  }
}
