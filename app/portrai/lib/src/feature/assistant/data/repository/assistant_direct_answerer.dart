import 'dart:convert';

/// Answers contact questions and "how long in a city or country" questions
/// straight from the portfolio JSON built by `GetAssistantContextUseCase`;
/// every other question is left to the on-device model, which garbles numbers
/// too often to be trusted with them. Returns null when the model is needed.
class AssistantDirectAnswerer {
  AssistantDirectAnswerer(String portfolioContext)
    : _portfolio = _decode(portfolioContext);

  final Map<String, dynamic> _portfolio;

  String? answer(String question) {
    final q = question.toLowerCase();
    return _contactAnswer(q) ?? _placeDurationAnswer(q);
  }

  static final _durationWords = RegExp(
    r'\b(how long|how many (years|months)|how much|experience|time|years|months|duration)\b',
  );
  static final _otherIntent = RegExp(
    r'\b(longest|shortest|first|last|current|which|compare|most|least|gap|language|speak)\b',
  );
  static final _cityEntry = RegExp(r'^([^:]+): (.+?) in (\d+) roles?\b(.*)$');
  static final _countryEntry = RegExp(r'^([^:]+): (.+?) \((.*)\)$');

  String? _placeDurationAnswer(String q) {
    if (!_durationWords.hasMatch(q) || _otherIntent.hasMatch(q)) return null;
    final overview = _portfolio['overview'];
    if (overview is! List) return null;
    final name = (_portfolio['profile'] as Map?)?['name'] ?? 'He';
    for (final line in overview.whereType<String>()) {
      final isCity = line.startsWith('Experience per city');
      if (!isCity && !line.startsWith('Total time worked per country')) {
        continue;
      }
      final body = line
          .substring(line.indexOf(': ') + 2)
          .replaceFirst(RegExp(r'\.$'), '');
      for (final entry in body.split('; ')) {
        final match = (isCity ? _cityEntry : _countryEntry).firstMatch(entry);
        if (match == null) continue;
        final place = match.group(1)!.trim();
        if (!RegExp(
          '\\b${RegExp.escape(place.toLowerCase())}\\b',
        ).hasMatch(q)) {
          continue;
        }
        final duration = match.group(2)!;
        if (!isCity) {
          return '$name worked $duration in $place (${match.group(3)}).';
        }
        final count = match.group(3)!;
        final roles = (match.group(4) ?? '')
            .replaceAll(RegExp(r'^\s*\(|\)\s*$'), '')
            .trim();
        return '$name worked $duration in $place, across $count '
            '${count == '1' ? 'role' : 'roles'}'
            '${roles.isEmpty ? '' : ': $roles'}.';
      }
    }
    return null;
  }

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
