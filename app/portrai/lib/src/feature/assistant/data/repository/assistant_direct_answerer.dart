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
    return _contactAnswer(q) ??
        _placeDurationAnswer(q) ??
        _technologyDurationAnswer(q) ??
        _overviewAnswer(q);
  }

  static final _durationWords = RegExp(
    r'\b(how long|how many (years|months)|how much|experience|time|years|months|duration)\b',
  );
  static final _otherIntent = RegExp(
    r'\b(longest|shortest|first|last|current|which|compare|most|least|gap|language|speak)\b',
  );
  static final _cityEntry = RegExp(r'^([^:]+): (.+?) in (\d+) roles?\b(.*)$');
  static final _countryEntry = RegExp(r'^([^:]+): (.+?) \((.*)\)$');

  String? _overviewLine(String prefix) {
    final overview = _portfolio['overview'];
    if (overview is! List) return null;
    for (final line in overview.whereType<String>()) {
      if (line.startsWith(prefix)) return line;
    }
    return null;
  }

  String get _name => '${(_portfolio['profile'] as Map?)?['name'] ?? 'He'}';

  // "Flutter: 5 years and 2 months; Android: 4 years" -> the entry named in
  // the question.
  String? _technologyDurationAnswer(String q) {
    if (!_durationWords.hasMatch(q) || _otherIntent.hasMatch(q)) return null;
    final line = _overviewLine('Time using each technology');
    if (line == null) return null;
    final body = line
        .substring(line.lastIndexOf('): ') + 3)
        .replaceFirst(RegExp(r'\.$'), '');
    for (final entry in body.split('; ')) {
      final parts = entry.split(': ');
      if (parts.length != 2) continue;
      final technology = parts.first.trim();
      if (RegExp(
        '(^|[^a-z0-9])${RegExp.escape(technology.toLowerCase())}(\$|[^a-z0-9+#])',
      ).hasMatch(q)) {
        return '$_name has used $technology for ${parts.last} across all '
            'roles, counting overlapping roles once.';
      }
    }
    return null;
  }

  static final _knownPlaceHint = RegExp(r'\b(in|at|from|for)\s+[a-z]+');

  // Ready-computed career facts, returned as written so the model cannot
  // garble the numbers. Questions that name a place are left to the model.
  String? _overviewAnswer(String q) {
    bool isAbout(String pattern) => RegExp(pattern).hasMatch(q);
    if (isAbout(r'\b(longest|shortest)\b') && !_knownPlaceHint.hasMatch(q)) {
      return _overviewLine(
        q.contains('longest') ? 'Longest role' : 'Shortest role',
      );
    }
    if (isAbout(r'\b(first|earliest)\s+(job|role|position|company)\b')) {
      return _overviewLine('First role');
    }
    if (isAbout(r'\b(current|present)\s+(job|role|position|company)\b') ||
        isAbout(r'\bwhere does he (work|currently work)\b')) {
      return _overviewLine('Current role');
    }
    if (isAbout(r'\bgaps?\b|\bchange jobs?\b|\bjob changes?\b')) {
      return _overviewLine('Career gaps');
    }
    if (isAbout(r'\b(led|lead|leads|leadership|managed)\b')) {
      return _overviewLine('Leadership roles');
    }
    if (isAbout(r'\bhow many (companies|roles|jobs|employers)\b')) {
      return _overviewLine('Career overview');
    }
    if (isAbout(r'\b(languages?)\b') &&
        isAbout(r'\b(speak|spoken|know|how many)\b')) {
      return _overviewLine('Spoken languages');
    }
    return null;
  }

  String? _placeDurationAnswer(String q) {
    if (!_durationWords.hasMatch(q) || _otherIntent.hasMatch(q)) return null;
    final overview = _portfolio['overview'];
    if (overview is! List) return null;
    final name = _name;
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
