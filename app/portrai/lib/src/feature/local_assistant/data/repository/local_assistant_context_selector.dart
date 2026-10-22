import 'dart:convert';

/// Selects facts from the complete portfolio without passing the entire
/// portfolio or an ever-growing conversation to the small on-device model.
class LocalAssistantContextSelector {
  static const maxContextBytes = 10000;
  static const _header =
      'Portfolio facts (selected for this question). Quote dates and '
      'durations exactly as written; never calculate or invent them.';

  // Keys that only serve the app's own screens. They would cost prompt space
  // and tempt the model into quoting image URLs and ids.
  static const _presentationKeys = {
    'id',
    'experienceId',
    'image',
    'profileImage',
    'profileImages',
    'coverImage',
    'companyLogo',
    'latitude',
    'longitude',
  };

  // Overview lines that only help career comparisons and are long enough to
  // crowd out the records otherwise.
  static const _longListPrefixes = ['All roles', 'Time using each technology'];

  // Sections whose records carry a proper name a question can refer to.
  static const _namedSections = {'experiences', 'projects', 'testimonials'};

  static const _chunkRunes = 300;
  static final _sentenceBoundary = RegExp(r'(?<=[.!?])\s+');
  static final _linksPath = RegExp(r'\.links(\[\d+\])?$');

  static bool _isLinks(String path) => _linksPath.hasMatch(path);

  // Long texts are split at sentence ends into parts of about 300 runes, so
  // no sentence, URL or number is cut in two.
  static List<String> _chunks(String text) {
    if (text.runes.length <= _chunkRunes) return [text];
    final chunks = <String>[];
    var current = StringBuffer();
    void flush() {
      if (current.isNotEmpty) chunks.add(current.toString());
      current = StringBuffer();
    }

    for (final sentence in text.split(_sentenceBoundary)) {
      final runes = sentence.runes.toList();
      if (runes.length > _chunkRunes) {
        flush();
        for (var start = 0; start < runes.length; start += _chunkRunes) {
          final end = start + _chunkRunes < runes.length
              ? start + _chunkRunes
              : runes.length;
          chunks.add(String.fromCharCodes(runes.sublist(start, end)));
        }
        continue;
      }
      if (current.isNotEmpty &&
          current.length + 1 + runes.length > _chunkRunes) {
        flush();
      }
      if (current.isNotEmpty) current.write(' ');
      current.write(sentence);
    }
    flush();
    return chunks;
  }

  /// Selects the facts of the decoded [portfolio] that are relevant to
  /// [question], within [maxBytes] of UTF-8.
  String select(
    Map<String, dynamic> portfolio,
    String question, {
    String? previousQuestion,
    int maxBytes = maxContextBytes,
  }) {
    // Every question is about the owner, so their name selects nothing.
    final ownerTerms = _terms(
      '${(portfolio['profile'] as Map?)?['name'] ?? ''}',
    );
    final terms = _questionTerms(question)..removeAll(ownerTerms);
    final countryTerms = _countryTerms(portfolio);
    final previousTerms = _questionTerms(previousQuestion ?? '')
      ..removeAll(ownerTerms);
    final asksTechnologyDuration =
        terms.intersection(_durationTerms).isNotEmpty &&
        terms.intersection(_technologyTerms(portfolio)).isNotEmpty;
    final asksLinks = terms.intersection(_linkTerms).isNotEmpty;
    // Project links lead only for a named project or a store question; a
    // resume or profile link question must not drown in them.
    final asksStores = _terms(question).intersection(_storeTerms).isNotEmpty;
    final isCareer =
        _mentionsYear(terms) ||
        asksTechnologyDuration ||
        terms.intersection(countryTerms).isNotEmpty ||
        terms.intersection(_careerTerms).isNotEmpty ||
        previousTerms.intersection(_careerTerms).isNotEmpty;
    final facts = <({String text, int score, int order})>[];

    void addFact(String text, int score) {
      facts.add((text: text, score: score, order: facts.length));
    }

    int scoreOf(String text, String path, int sourceScore) {
      final words = _terms(text);
      // A ready-written summary leads its own record and career questions;
      // for anything else it only outranks facts that match nothing.
      final summaryScore = !path.endsWith('.summary')
          ? 0
          : sourceScore > 0 || isCareer
          ? 50
          : 8;
      return sourceScore +
          terms.intersection(words).length * 10 +
          previousTerms.intersection(words).length +
          (path.endsWith('.title') || path.endsWith('.company') ? 2 : 0) +
          summaryScore +
          (_isLinks(path) && asksLinks && (sourceScore > 0 || asksStores)
              ? 40
              : 0);
    }

    void addFacts(Object? value, String path, int sourceScore) {
      if (value == null) return;
      if (value is Map<String, dynamic>) {
        final entries = value.entries.where(
          (entry) =>
              !_presentationKeys.contains(entry.key) && entry.value != null,
        );
        // A short record of plain values, such as a skill or a market, stays
        // on one line so the model sees its name next to its level or links.
        if (entries.isEmpty) return;
        if (entries.every(
          (entry) => entry.value is! Map && entry.value is! List,
        )) {
          final text =
              '$path: ${entries.map((entry) => '${entry.key}: ${entry.value}').join(', ')}';
          if (text.runes.length <= _chunkRunes) {
            addFact(text, scoreOf(text, path, sourceScore));
            return;
          }
        }
        for (final entry in entries) {
          addFacts(entry.value, '$path.${entry.key}', sourceScore);
        }
      } else if (value is List) {
        if (value.isEmpty) {
          final text = '$path: none listed';
          addFact(text, scoreOf(text, path, sourceScore));
          return;
        }
        for (var index = 0; index < value.length; index++) {
          addFacts(value[index], '$path[$index]', sourceScore);
        }
      } else {
        // Split unusually long descriptions without discarding their contents
        // from the searchable source. Each part retains its source label.
        final isSentence = path.endsWith('.summary') || _isLinks(path);
        for (final part in _chunks('$value')) {
          final text = isSentence ? part : '$path: $part';
          addFact(text, scoreOf(text, path, sourceScore));
        }
      }
    }

    for (final section in portfolio.entries) {
      if (section.key == 'overview') {
        // Precomputed rankings: only relevant to career questions, and then
        // more useful than any individual record. Comparisons outrank
        // everything; otherwise a named company's own facts must stay first.
        final score =
            _mentionsYear(terms) ||
                asksTechnologyDuration ||
                terms.intersection(countryTerms).isNotEmpty ||
                terms.intersection(_comparisonTerms).isNotEmpty
            ? 1000
            : 20;
        // The short summary lines are always offered, so a question phrased
        // in words nobody anticipated still sees the basics (education,
        // languages, first and current role) after the facts that match it.
        // Only the long lists need a matching question.
        for (final line in section.value as List) {
          final isLongList = _longListPrefixes.any('$line'.startsWith);
          if (isLongList && !isCareer) continue;
          addFact('$line', isCareer ? score : 9);
        }
      } else if (section.key == 'digest') {
        // Every record in one line; the ones matching the question first,
        // the rest after the matching facts.
        for (final line in section.value as List) {
          addFact('$line', 9 + terms.intersection(_terms('$line')).length * 8);
        }
      } else if (section.key == 'asOf') {
        addFact("Today's date: ${section.value}", 0);
      } else if (section.value is List) {
        final records = section.value as List;
        // A question naming the section ("testimonials", "services") wants
        // its records ahead of the digest.
        final sectionScore = terms.intersection(_terms(section.key)).isNotEmpty
            ? 30
            : 0;
        for (var index = 0; index < records.length; index++) {
          final record = records[index];
          if (record is! Map<String, dynamic>) {
            throw const FormatException('Portfolio records must be objects.');
          }
          final identity = [
            record['company'],
            record['title'],
            record['name'],
          ].whereType<String>().join(' ');
          // Only proper names (a company, a project, a person) identify a
          // record; a service or skill group title made of everyday words
          // ("Intelligent Apps") earns no more than its word matches.
          final identityTerms = _namedSections.contains(section.key)
              ? _terms(identity)
              : const <String>{};
          final sourceScore = terms.intersection(identityTerms).isNotEmpty
              ? 100
              : previousTerms.intersection(identityTerms).isNotEmpty
              ? 40
              : 0;
          addFacts(
            record,
            '${section.key}[$index] ($identity)',
            sourceScore + sectionScore,
          );
        }
      } else {
        addFacts(section.value, section.key, 0);
      }
    }
    facts.sort((first, second) {
      final priority = second.score.compareTo(first.score);
      return priority == 0 ? first.order.compareTo(second.order) : priority;
    });

    final selected = <String>[_header];
    var bytes = utf8.encode(selected.join('\n')).length;
    for (final fact in facts) {
      final size = utf8.encode(fact.text).length + 1;
      if (bytes + size <= maxBytes) {
        selected.add(fact.text);
        bytes += size;
      }
    }
    return selected.join('\n');
  }

  static final _followUpPattern = RegExp(
    r'\b(else|also|more|that|those|there|it|them|again|another|other)\b|'
    r'^(and|in|for|what about|how about)\b',
    caseSensitive: false,
  );

  /// Whether [question] refers back to the previous one: it uses a pronoun
  /// or a continuation and names no company, project, technology or person
  /// of the [portfolio] itself.
  static bool isFollowUp(Map<String, dynamic> portfolio, String question) {
    final trimmed = question.trim();
    return _followUpPattern.hasMatch(trimmed) &&
        !mentionsPortfolioName(portfolio, trimmed);
  }

  /// Whether [question] names a company, project, technology or testimonial
  /// author of the [portfolio], as a whole name or as a company's first word
  /// ("MediaMarkt" for "MediaMarkt Saturn").
  static bool mentionsPortfolioName(
    Map<String, dynamic> portfolio,
    String question,
  ) {
    final normalizedQuestion = question.toLowerCase();
    return portfolioNames(
      portfolio,
    ).any((name) => _namePattern(name).hasMatch(normalizedQuestion));
  }

  /// The lower-case names a question can refer to: companies and their
  /// first word, project titles, technologies and testimonial authors.
  static Set<String> portfolioNames(Map<String, dynamic> portfolio) {
    List<Map<String, dynamic>> records(String section) =>
        (portfolio[section] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
    final names = <String>{
      for (final record in records('experiences')) ...[
        '${record['company'] ?? ''}',
        '${record['company'] ?? ''}'.split(' ').first,
        for (final technology in record['technologies'] as List? ?? const [])
          '$technology',
      ],
      for (final record in records('projects')) ...[
        '${record['title'] ?? ''}',
        for (final technology in record['technologies'] as List? ?? const [])
          '$technology',
      ],
      for (final record in records('testimonials')) '${record['name'] ?? ''}',
    };
    return {
      for (final name in names)
        if (name.trim().length >= 4) name.trim().toLowerCase(),
    };
  }

  static final _namePatterns = <String, RegExp>{};

  static RegExp _namePattern(String name) => _namePatterns.putIfAbsent(
    name,
    () => RegExp('(^|[^a-z0-9])${RegExp.escape(name)}(\$|[^a-z0-9+#])'),
  );

  // Words of every city and country that appears in an experience location.
  static Set<String> _countryTerms(Map<String, dynamic> portfolio) {
    final experiences = portfolio['experiences'];
    if (experiences is! List) return const {};
    return {
      for (final item in experiences.whereType<Map<String, dynamic>>())
        ..._terms('${item['location']}'.replaceAll(_bracketedNote, '')),
      'country',
      'countries',
    };
  }

  static const _durationTerms = {
    'long',
    'years',
    'year',
    'months',
    'many',
    'much',
  };

  static const _storeTerms = {
    'store',
    'stores',
    'playstore',
    'appstore',
    'app',
    'apps',
    'project',
    'projects',
  };

  static const _linkTerms = {
    'link',
    'links',
    'url',
    'urls',
    'store',
    'playstore',
    'appstore',
    'website',
    'github',
    'download',
    'install',
  };

  // Words of every technology listed on an experience.
  static Set<String> _technologyTerms(Map<String, dynamic> portfolio) {
    final experiences = portfolio['experiences'];
    if (experiences is! List) return const {};
    return {
      for (final item in experiences.whereType<Map<String, dynamic>>())
        for (final technology in (item['technologies'] as List? ?? const []))
          ..._terms('$technology'),
    };
  }

  static final _bracketedNote = RegExp(r'\[.*?\]');
  static final _year = RegExp(r'^(19|20)\d{2}$');
  static final _camelCaseBoundary = RegExp(r'([a-z])([A-Z])');
  static final _word = RegExp(r'[\p{L}\p{N}]+', unicode: true);

  static bool _mentionsYear(Set<String> terms) => terms.any(_year.hasMatch);

  /// The searchable words of a fact or a question.
  static Set<String> _terms(String text) {
    // Split camelCase field names too, so "date" matches "startDate".
    final spaced = text.replaceAllMapped(
      _camelCaseBoundary,
      (match) => '${match[1]} ${match[2]}',
    );
    return _word
        .allMatches(spaced.toLowerCase())
        .map((match) => match.group(0)!)
        .where((word) => word.length > 1 && !_stopWords.contains(word))
        .toSet();
  }

  /// The words of a question, widened with the field and section names its
  /// wording implies. Facts are not widened, so "long" in "how long" never
  /// matches every "longDescription".
  static Set<String> _questionTerms(String question) {
    final terms = _terms(question);
    if (terms.intersection({
      'long',
      'duration',
      'tenure',
      'dates',
      'date',
      'years',
      'months',
    }).isNotEmpty) {
      terms
        ..addAll({'start', 'end', 'date', 'calendar', 'months'})
        ..remove('long');
    }
    if (terms.intersection({
      'experience',
      'employment',
      'worked',
      'work',
    }).isNotEmpty) {
      terms.addAll({'experiences', 'company', 'position'});
    }
    if (terms.contains('playstore')) terms.addAll({'play', 'store'});
    if (terms.contains('appstore')) terms.addAll({'app', 'store'});
    if (terms.intersection({'resume', 'cv'}).isNotEmpty) {
      terms.addAll({'resume', 'url'});
    }
    if (terms.intersection({
      'app',
      'apps',
      'playstore',
      'appstore',
    }).isNotEmpty) {
      terms.add('projects');
    }
    if (terms.intersection(_educationTerms).isNotEmpty) {
      terms.addAll({'education', 'educations', 'institution', 'degree'});
    }
    if (terms.intersection({'skill', 'skills'}).isNotEmpty) {
      terms.addAll({'skills', 'expertises'});
    }
    for (final section in {
      'project',
      'service',
      'testimonial',
      'language',
      'achievement',
      'responsibility',
      'certification',
    }) {
      final plural = section == 'responsibility'
          ? 'responsibilities'
          : '${section}s';
      if (terms.contains(section) || terms.contains(plural)) {
        terms.addAll({section, plural});
      }
    }
    if (terms.contains('contact')) terms.addAll({'name', 'email', 'phone'});
    if (terms.intersection({
      'live',
      'lives',
      'living',
      'based',
      'located',
      'where',
      'timezone',
    }).isNotEmpty) {
      // Not "country": that word also selects the career totals.
      terms.addAll({'location', 'city', 'based', 'timezone'});
    }
    return terms;
  }

  static const _educationTerms = {
    'education',
    'study',
    'studied',
    'studies',
    'school',
    'university',
    'college',
    'degree',
    'graduated',
    'graduate',
    'qualification',
    'qualifications',
  };

  static const _comparisonTerms = {
    ..._educationTerms,
    'earliest',
    'shortest',
    'longest',
    'short',
    'longer',
    'most',
    'least',
    'many',
    'current',
    'currently',
    'all',
    'list',
    'companies',
    'roles',
    'career',
    'first',
    'latest',
    'recent',
    'oldest',
    'language',
    'languages',
    'speak',
    'speaks',
    'spoken',
    'gap',
    'gaps',
    'often',
    'frequently',
    'changed',
    'lead',
    'led',
    'leader',
    'leadership',
    'team',
    'manage',
    'total',
    'overall',
  };

  static const _careerTerms = {
    ..._educationTerms,
    'earliest',
    'remote',
    'freelance',
    'remoto',
    'language',
    'languages',
    'speak',
    'speaks',
    'spoken',
    'gap',
    'gaps',
    'often',
    'frequently',
    'changed',
    'lead',
    'led',
    'leader',
    'leadership',
    'team',
    'manage',
    'senior',
    'experience',
    'experiences',
    'company',
    'companies',
    'employer',
    'employers',
    'role',
    'roles',
    'job',
    'jobs',
    'career',
    'work',
    'worked',
    'working',
    'position',
    'shortest',
    'longest',
    'short',
    'long',
    'current',
    'currently',
    'duration',
    'tenure',
    'years',
    'months',
    'total',
    'overall',
  };

  static const _stopWords = {
    'the',
    'is',
    'was',
    'in',
    'at',
    'of',
    'to',
    'for',
    'and',
    'or',
    'me',
    'tell',
    'how',
    'what',
    'who',
    'about',
    'it',
    'his',
    'he',
    'him',
    'you',
    'an',
    'any',
    'does',
    'did',
    'do',
    'has',
    'have',
    'had',
    'are',
    'be',
    'been',
    'can',
    'could',
    'would',
    'should',
    'please',
    'with',
    'on',
    'by',
    'as',
  };
}
