import 'package:portrai/src/feature/local_assistant/data/repository/local_assistant_context_selector.dart';

/// One deterministic answer: [applies] decides whether the question asks for
/// it, [answer] builds it from the portfolio or returns null when the
/// portfolio lacks the fact.
class _Rule {
  const _Rule({required this.applies, required this.answer});

  final bool Function(String normalizedQuestion) applies;
  final String? Function(String normalizedQuestion) answer;
}

/// Answers contact, tenure and career-overview questions straight from the
/// decoded portfolio JSON built by `GetAssistantContextUseCase`; every other
/// question is left to the on-device model, which garbles numbers too often
/// to be trusted with them. Returns null when the model is needed.
///
/// Each answer is a [_Rule]; the first rule that applies and finds its fact
/// wins, so a more specific rule must come before a broader one.
class LocalAssistantDirectAnswerer {
  LocalAssistantDirectAnswerer(this._portfolio);

  final Map<String, dynamic> _portfolio;

  late final List<_Rule> _rules = [
    _Rule(
      applies: (question) =>
          !_productWords.hasMatch(question) && !_namesPortfolioEntity(question),
      answer: _contactAnswer,
    ),
    _Rule(applies: _asksDuration, answer: _placeDurationAnswer),
    _Rule(applies: _asksDuration, answer: _companyDurationAnswer),
    _Rule(applies: _asksDuration, answer: _technologyDurationAnswer),
    _Rule(
      applies: (question) =>
          _totalExperience.hasMatch(question) &&
          !_otherIntent.hasMatch(question) &&
          !_namesPortfolioEntity(question) &&
          !_namesPlace(question),
      answer: (_) => _totalExperienceAnswer(),
    ),
    _overviewRule(
      (question) =>
          _longestOrShortest.hasMatch(question) &&
          _roleWords.hasMatch(question) &&
          !_knownPlaceHint.hasMatch(question),
      (question) => _possessive(
        _overviewLine(
          question.contains('longest') ? 'Longest role' : 'Shortest role',
        ),
      ),
    ),
    _overviewRule(
      _firstRole.hasMatch,
      (_) => _possessive(_overviewLine('First role')),
    ),
    _overviewRule(
      _currentRole.hasMatch,
      (_) => _possessive(_overviewLine('Current role')),
    ),
    _overviewRule(
      _careerGaps.hasMatch,
      (_) => _possessive(_overviewLine('Career gaps')),
    ),
    _overviewRule(
      _leadership.hasMatch,
      (_) => _possessive(_overviewLine('Leadership roles')),
    ),
    _overviewRule(
      _roleCount.hasMatch,
      (_) => _possessive(_overviewLine('Career overview')),
    ),
    _overviewRule(
      (question) =>
          _languages.hasMatch(question) &&
          _languageKnowledge.hasMatch(question) &&
          !_programming.hasMatch(question),
      (_) => _spokenLanguagesAnswer(),
    ),
  ];

  String? answer(String question) {
    final normalizedQuestion = question.toLowerCase();
    for (final rule in _rules) {
      if (!rule.applies(normalizedQuestion)) continue;
      final answer = rule.answer(normalizedQuestion);
      if (answer != null) return answer;
    }
    return null;
  }

  // Ready-computed career facts, returned as written so the model cannot
  // garble the numbers. Questions that name a company, project or person are
  // left to the model, which sees that record's own facts.
  _Rule _overviewRule(
    bool Function(String normalizedQuestion) matches,
    String? Function(String normalizedQuestion) answer,
  ) => _Rule(
    applies: (question) =>
        matches(question) && !_namesPortfolioEntity(question),
    answer: answer,
  );

  bool _asksDuration(String normalizedQuestion) =>
      _durationWords.hasMatch(normalizedQuestion) &&
      !_otherIntent.hasMatch(normalizedQuestion);

  static final _durationWords = RegExp(
    r'\b(how long|how many (years|months)|how much (time|experience)|years of|months of|duration|tenure|length of)\b',
  );
  static final _otherIntent = RegExp(
    r'\b(longest|shortest|first|last|current|which|compare|most|least|gaps?|languages?|speak)\b',
  );
  static final _cityEntry = RegExp(r'^([^:]+): (.+?) in (\d+) roles?\b(.*)$');
  static final _countryEntry = RegExp(r'^([^:]+): (.+?) \((.*)\)$');
  static final _companyEntry = RegExp(
    r'([^:;()]+?): (\d+ (?:years?|months?)(?: and \d+ months?)?) in (\d+) roles? \(([^)]*)\)',
  );
  static final _totalExperienceLine = RegExp(
    r'^Total professional experience: (.+?) \((.+?)\)',
  );
  static final _trailingPeriod = RegExp(r'\.$');
  static final _leadingSeparator = RegExp(r'^[\s.]+');
  static final _spokenLanguages = RegExp(
    r'^Spoken languages \((\d+)\): (.+?)\.',
  );
  static final _enclosingParentheses = RegExp(r'^\s*\(|\)\s*$');
  static final _longestOrShortest = RegExp(r'\b(longest|shortest)\b');
  static final _roleWords = RegExp(
    r'\b(jobs?|roles?|positions?|company|companies|employers?|employment|tenure|stint|worked|work)\b',
  );
  static final _firstRole = RegExp(
    r'\b(first|earliest)\s+(job|role|position|company|employer)\b',
  );
  static final _currentRole = RegExp(
    r'\b(current|present|latest)\s+(job|role|position|company|employer)\b|'
    r'\b(where|who) (does|is) he (work|working|employed)\b|'
    r'\b(work|working|employed) (now|today|currently|at the moment)\b|'
    r'\bwho employs him\b',
  );
  static final _careerGaps = RegExp(
    r'\bgaps?\b|\bchange jobs?\b|\bjob changes?\b',
  );
  static final _leadership = RegExp(
    r'\b(led|lead|leads|leading|managed|manages|manage|mentored)\b.*\b(team|teams|people|developers|engineers)\b|'
    r'\b(team|teams|people|developers|engineers)\b.*\b(led|lead|leads|leading|managed|manages|manage|mentored)\b|'
    r'\b(leadership|leader)\b',
  );
  static final _roleCount = RegExp(
    r'\bhow many (companies|roles|jobs|employers)\b',
  );
  static final _languages = RegExp(r'\b(languages?)\b');
  static final _languageKnowledge = RegExp(
    r'\b(speak|speaks|spoken|know|knows|how many|fluent|native)\b',
  );
  static final _programming = RegExp(
    r'\b(programming|coding|code|development|technical|scripting|computer|software)\b',
  );
  static final _totalExperience = RegExp(
    r'\b(total|overall)\b.*\bexperience\b|'
    r'\byears of (professional |work |working )?experience\b|'
    r'\bhow (many years|long)\b.*\b(experience|working|worked|career|industry)\b',
  );
  static final _email = RegExp(r'\be-?mails?\b');
  static final _phone = RegExp(r'\b(phone|telephone|whatsapp|call)\b');
  static final _contact = RegExp(r'\b(contact|reach|get in touch|in touch)\b');
  // A question about something he built, not about reaching him.
  static final _productWords = RegExp(
    r'\b(apps?|application|projects?|features?|build|built|develop|developed|screen|form)\b',
  );
  static final _knownPlaceHint = RegExp(r'\b(in|at|from|for)\s+[a-z]+');

  // Technology and place names come from the portfolio, a small fixed set, so
  // their patterns are built once and reused across questions.
  static final _namePatterns = <String, RegExp>{};

  static RegExp _namePattern(String name) => _namePatterns.putIfAbsent(
    name,
    () => RegExp(
      '(^|[^a-z0-9])${RegExp.escape(name.toLowerCase())}(\$|[^a-z0-9+#])',
    ),
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

  bool _namesPortfolioEntity(String normalizedQuestion) =>
      LocalAssistantContextSelector.mentionsPortfolioName(
        _portfolio,
        normalizedQuestion,
      );

  // "Technology: duration; ..." entries of an overview line, longest name
  // first so "Android SDK" wins over "Android".
  List<(String, String)> _entries(String prefix) {
    final line = _overviewLine(prefix);
    if (line == null) return const [];
    final body = line
        .substring(line.lastIndexOf('): ') + 3)
        .replaceFirst(_trailingPeriod, '');
    final entries = <(String, String)>[];
    for (final entry in body.split('; ')) {
      final parts = entry.split(': ');
      if (parts.length == 2) entries.add((parts.first.trim(), parts.last));
    }
    return entries..sort(
      (longer, shorter) => shorter.$1.length.compareTo(longer.$1.length),
    );
  }

  // "Flutter: 5 years and 2 months; Android: 4 years" -> the entry named in
  // the question.
  String? _technologyDurationAnswer(String normalizedQuestion) {
    for (final (technology, duration) in _entries(
      'Time using each technology',
    )) {
      if (_namePattern(technology).hasMatch(normalizedQuestion)) {
        return '$_name has used $technology for $duration across all '
            'roles, counting overlapping roles once.';
      }
    }
    return null;
  }

  // "MediaMarkt Saturn: 3 years and 7 months in 2 roles (...)" -> the company
  // named in the question, as its full name or its first word.
  String? _companyDurationAnswer(String normalizedQuestion) {
    final line = _overviewLine('Time per company');
    if (line == null) return null;
    for (final match in _companyEntry.allMatches(line)) {
      final company = match.group(1)!.replaceFirst(_leadingSeparator, '');
      final firstWord = company.split(' ').first;
      final isNamed =
          _namePattern(company).hasMatch(normalizedQuestion) ||
          (firstWord.length >= 4 &&
              _namePattern(firstWord).hasMatch(normalizedQuestion));
      if (!isNamed) continue;
      final duration = match.group(2)!;
      final count = match.group(3)!;
      final roles = match.group(4)!;
      return count == '1'
          ? '$_name worked at $company for $duration as $roles.'
          : '$_name worked at $company for $duration across $count roles: '
                '$roles.';
    }
    return null;
  }

  // "Total professional experience: 10 years (July 2015 to present), ..."
  // for a question about the whole career rather than a place, company or
  // technology.
  String? _totalExperienceAnswer() {
    final line = _overviewLine('Total professional experience');
    if (line == null) return null;
    final match = _totalExperienceLine.firstMatch(line);
    if (match == null) return null;
    return '$_name has ${match.group(1)} of professional experience '
        '(${match.group(2)}), counting overlapping roles once.';
  }

  // "Longest role: X." -> "Mayank Rai's longest role: X."
  String? _possessive(String? line) {
    if (line == null || line.isEmpty) return line;
    return "$_name's ${line[0].toLowerCase()}${line.substring(1)}";
  }

  // "Spoken languages (2): English (Fluent), Spanish (Proficient). ..." ->
  // "Mayank Rai speaks 2 languages: English (Fluent), Spanish (Proficient)."
  String? _spokenLanguagesAnswer() {
    final line = _overviewLine('Spoken languages');
    if (line == null) return null;
    final match = _spokenLanguages.firstMatch(line);
    if (match == null) return line;
    final count = match.group(1)!;
    return '$_name speaks $count ${count == '1' ? 'language' : 'languages'}: '
        '${match.group(2)}.';
  }

  bool _namesPlace(String normalizedQuestion) {
    for (final (place, _) in _places()) {
      if (_namePattern(place).hasMatch(normalizedQuestion)) return true;
    }
    return false;
  }

  // Every city and country of the overview with its entry, cities first.
  List<(String, ({bool isCity, RegExpMatch match}))> _places() {
    final overview = _portfolio['overview'];
    if (overview is! List) return const [];
    final places = <(String, ({bool isCity, RegExpMatch match}))>[];
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
        places.add((match.group(1)!.trim(), (isCity: isCity, match: match)));
      }
    }
    return places;
  }

  String? _placeDurationAnswer(String normalizedQuestion) {
    final name = _name;
    for (final (place, (:isCity, :match)) in _places()) {
      if (!_namePattern(place).hasMatch(normalizedQuestion)) continue;
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
    return null;
  }

  // Contact details and social links. The rule skips questions about a
  // product ("a contact app") or a named company or project ("the GitHub
  // link for MediaMarkt"), which the model answers from that record.
  String? _contactAnswer(String normalizedQuestion) {
    final profile = _portfolio['profile'];
    if (profile is! Map<String, dynamic>) return null;
    final name = _name;
    final email = _text(profile['email']);
    final phone = _text(profile['phone']);
    final socialLink = _socialLink(profile, normalizedQuestion);
    if (socialLink case (final network, final url)) {
      return "$name's $network: $url";
    }
    if (_email.hasMatch(normalizedQuestion) && email != null) {
      return "$name's email is $email.";
    }
    if (_phone.hasMatch(normalizedQuestion) && phone != null) {
      return "$name's phone number is $phone.";
    }
    if (_contact.hasMatch(normalizedQuestion)) {
      return switch ((email, phone)) {
        (final email?, final phone?) =>
          'You can contact $name by email at $email or by phone at $phone.',
        (final email?, null) => 'You can contact $name by email at $email.',
        (null, final phone?) => 'You can contact $name by phone at $phone.',
        _ => null,
      };
    }
    return null;
  }

  // The social link whose network ("LinkedIn", "GitHub") the question names.
  (String, String)? _socialLink(
    Map<String, dynamic> profile,
    String normalizedQuestion,
  ) {
    final links = profile['socialLinks'];
    if (links is! List) return null;
    for (final link in links.whereType<Map<String, dynamic>>()) {
      final network = _text(link['name']);
      final url = _text(link['url']);
      if (network == null || url == null) continue;
      if (_namePattern(network).hasMatch(normalizedQuestion)) {
        return (network, url);
      }
    }
    return null;
  }

  static String? _text(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }
}
