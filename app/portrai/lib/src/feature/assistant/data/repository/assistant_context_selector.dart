import 'dart:convert';

/// Selects facts from the complete portfolio without passing the entire
/// portfolio or an ever-growing conversation to the small on-device model.
class AssistantContextSelector {
  static const maxContextBytes = 5500;
  static const _header =
      'Portfolio facts (selected for this question). Quote dates and '
      'durations exactly as written; never calculate or invent them.';

  String select(
    String portfolioContext,
    String question, {
    String? previousQuestion,
    int maxBytes = maxContextBytes,
  }) {
    final decoded = jsonDecode(portfolioContext);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Assistant context must be a portfolio object.',
      );
    }
    final terms = _terms(question);
    final countryTerms = _countryTerms(decoded);
    final previousTerms = _terms(previousQuestion ?? '');
    final asksTechnologyDuration =
        terms.intersection(_durationTerms).isNotEmpty &&
        terms.intersection(_technologyTerms(decoded)).isNotEmpty;
    final facts = <({String text, int score, int order})>[];

    void addFacts(Object? value, String path, int sourceScore) {
      if (value is Map<String, dynamic>) {
        for (final entry in value.entries) {
          addFacts(entry.value, '$path.${entry.key}', sourceScore);
        }
      } else if (value is List) {
        for (var index = 0; index < value.length; index++) {
          addFacts(value[index], '$path[$index]', sourceScore);
        }
      } else {
        // Split unusually long descriptions without discarding their contents
        // from the searchable source. Each part retains its source label.
        final runes = '${value ?? 'not provided'}'.runes.toList();
        for (var start = 0; start < runes.length; start += 300) {
          final end = start + 300 < runes.length ? start + 300 : runes.length;
          final isSummary = path.endsWith('.summary');
          final text = isSummary
              ? String.fromCharCodes(runes.sublist(start, end))
              : '$path: ${String.fromCharCodes(runes.sublist(start, end))}';
          final words = _terms(text);
          final score =
              sourceScore +
              terms.intersection(words).length * 10 +
              previousTerms.intersection(words).length +
              (path.endsWith('.title') || path.endsWith('.company') ? 2 : 0) +
              (isSummary ? 50 : 0);
          facts.add((text: text, score: score, order: facts.length));
        }
      }
    }

    for (final section in decoded.entries) {
      if (section.key == 'overview') {
        // Precomputed rankings: only relevant to career questions, and then
        // more useful than any individual record.
        final isCareer =
            _mentionsYear(terms) ||
            asksTechnologyDuration ||
            terms.intersection(countryTerms).isNotEmpty ||
            terms.intersection(_careerTerms).isNotEmpty ||
            previousTerms.intersection(_careerTerms).isNotEmpty;
        // Comparisons outrank everything; otherwise a named company's own
        // facts must stay first.
        final score =
            _mentionsYear(terms) ||
                asksTechnologyDuration ||
                terms.intersection(countryTerms).isNotEmpty ||
                terms.intersection(_comparisonTerms).isNotEmpty
            ? 1000
            : 20;
        // The short summary lines are always offered, so a question phrased
        // in words nobody anticipated still sees the basics (education,
        // languages, first and current role). Only the long lists need a
        // matching question.
        for (final line in section.value as List) {
          final isLongList = '$line'.startsWith('All roles');
          if (isLongList && !isCareer) continue;
          facts.add((
            text: '$line',
            score: isCareer ? score : 20,
            order: facts.length,
          ));
        }
      } else if (section.value is List) {
        final records = section.value as List;
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
          final identityTerms = _terms(identity);
          final sourceScore = terms.intersection(identityTerms).isNotEmpty
              ? 100
              : previousTerms.intersection(identityTerms).isNotEmpty
              ? 40
              : 0;
          addFacts(record, '${section.key}[$index] ($identity)', sourceScore);
        }
      } else {
        addFacts(section.value, section.key, 0);
      }
    }
    facts.sort((a, b) {
      final priority = b.score.compareTo(a.score);
      return priority == 0 ? a.order.compareTo(b.order) : priority;
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

  // Words of every city and country that appears in an experience location.
  static Set<String> _countryTerms(Map<String, dynamic> portfolio) {
    final experiences = portfolio['experiences'];
    if (experiences is! List) return const {};
    return {
      for (final item in experiences.whereType<Map<String, dynamic>>())
        ..._terms('${item['location']}'.replaceAll(RegExp(r'\[.*?\]'), '')),
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

  // Words of every technology listed on an experience.
  static Set<String> _technologyTerms(Map<String, dynamic> portfolio) {
    final experiences = portfolio['experiences'];
    if (experiences is! List) return const {};
    return {
      for (final item in experiences.whereType<Map<String, dynamic>>())
        for (final tech in (item['technologies'] as List? ?? const []))
          ..._terms('$tech'),
    };
  }

  static bool _mentionsYear(Set<String> terms) =>
      terms.any((term) => RegExp(r'^(19|20)\d{2}$').hasMatch(term));

  static Set<String> _terms(String text) {
    // Split camelCase field names too, so "date" matches "startDate".
    final spaced = text.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match[1]} ${match[2]}',
    );
    final terms = RegExp(r'[\p{L}\p{N}]+', unicode: true)
        .allMatches(spaced.toLowerCase())
        .map((match) => match.group(0)!)
        .where((word) => word.length > 1 && !_stopWords.contains(word))
        .toSet();
    if (terms.intersection({
      'long',
      'duration',
      'tenure',
      'dates',
      'date',
      'years',
      'months',
    }).isNotEmpty) {
      terms.addAll({'start', 'end', 'date', 'calendar', 'months'});
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
    if (terms.intersection({'link', 'links', 'url', 'download'}).isNotEmpty) {
      terms.addAll({'links', 'store', 'website', 'github'});
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
    if (terms.contains('skills')) terms.add('expertises');
    for (final section in {
      'project',
      'service',
      'testimonial',
      'language',
      'achievement',
      'responsibility',
    }) {
      if (terms.contains(section)) {
        terms.add(
          section == 'responsibility' ? 'responsibilities' : '${section}s',
        );
      }
    }
    if (terms.contains('contact')) terms.addAll({'name', 'email', 'phone'});
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
    'me',
    'tell',
    'how',
    'what',
    'who',
    'about',
    'it',
    'his',
    'he',
    'you',
  };
}
