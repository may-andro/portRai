/// Answers contact questions and "how long in a city or country" questions
/// straight from the decoded portfolio JSON built by
/// `GetAssistantContextUseCase`; every other question is left to the
/// on-device model, which garbles numbers too often to be trusted with them.
/// Returns null when the model is needed.
class LocalAssistantDirectAnswerer {
  const LocalAssistantDirectAnswerer(this._portfolio);

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
  static final _trailingPeriod = RegExp(r'\.$');
  static final _enclosingParentheses = RegExp(r'^\s*\(|\)\s*$');
  static final _longestOrShortest = RegExp(r'\b(longest|shortest)\b');
  static final _firstRole = RegExp(
    r'\b(first|earliest)\s+(job|role|position|company)\b',
  );
  static final _currentRole = RegExp(
    r'\b(current|present)\s+(job|role|position|company)\b',
  );
  static final _currentWorkplace = RegExp(
    r'\bwhere does he (work|currently work)\b',
  );
  static final _careerGaps = RegExp(
    r'\bgaps?\b|\bchange jobs?\b|\bjob changes?\b',
  );
  static final _leadership = RegExp(r'\b(led|lead|leads|leadership|managed)\b');
  static final _roleCount = RegExp(
    r'\bhow many (companies|roles|jobs|employers)\b',
  );
  static final _languages = RegExp(r'\b(languages?)\b');
  static final _languageKnowledge = RegExp(r'\b(speak|spoken|know|how many)\b');

  // Technology and place names come from the portfolio, a small fixed set, so
  // their patterns are built once and reused across questions.
  static final _technologyPatterns = <String, RegExp>{};
  static final _placePatterns = <String, RegExp>{};

  static RegExp _technologyPattern(
    String technology,
  ) => _technologyPatterns.putIfAbsent(
    technology,
    () => RegExp(
      '(^|[^a-z0-9])${RegExp.escape(technology.toLowerCase())}(\$|[^a-z0-9+#])',
    ),
  );

  static RegExp _placePattern(String place) => _placePatterns.putIfAbsent(
    place,
    () => RegExp('\\b${RegExp.escape(place.toLowerCase())}\\b'),
  );

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
        .replaceFirst(_trailingPeriod, '');
    for (final entry in body.split('; ')) {
      final parts = entry.split(': ');
      if (parts.length != 2) continue;
      final technology = parts.first.trim();
      if (_technologyPattern(technology).hasMatch(q)) {
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
    bool isAbout(RegExp pattern) => pattern.hasMatch(q);
    if (isAbout(_longestOrShortest) && !_knownPlaceHint.hasMatch(q)) {
      return _overviewLine(
        q.contains('longest') ? 'Longest role' : 'Shortest role',
      );
    }
    if (isAbout(_firstRole)) {
      return _overviewLine('First role');
    }
    if (isAbout(_currentRole) || isAbout(_currentWorkplace)) {
      return _overviewLine('Current role');
    }
    if (isAbout(_careerGaps)) {
      return _overviewLine('Career gaps');
    }
    if (isAbout(_leadership)) {
      return _overviewLine('Leadership roles');
    }
    if (isAbout(_roleCount)) {
      return _overviewLine('Career overview');
    }
    if (isAbout(_languages) && isAbout(_languageKnowledge)) {
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
          .replaceFirst(_trailingPeriod, '');
      for (final entry in body.split('; ')) {
        final match = (isCity ? _cityEntry : _countryEntry).firstMatch(entry);
        if (match == null) continue;
        final place = match.group(1)!.trim();
        if (!_placePattern(place).hasMatch(q)) {
          continue;
        }
        final duration = match.group(2)!;
        if (!isCity) {
          return '$name worked $duration in $place (${match.group(3)}).';
        }
        final count = match.group(3)!;
        final roles = (match.group(4) ?? '')
            .replaceAll(_enclosingParentheses, '')
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
}
