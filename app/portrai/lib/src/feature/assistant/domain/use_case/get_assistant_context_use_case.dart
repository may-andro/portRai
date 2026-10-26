import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/portfolio/portfolio.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:use_case/use_case.dart';

sealed class GetAssistantContextFailure extends BasicFailure {
  const GetAssistantContextFailure({super.cause});
}

class GetAssistantContextUnknownFailure extends GetAssistantContextFailure {
  const GetAssistantContextUnknownFailure({super.cause});
}

@register
class GetAssistantContextUseCase
    extends BaseNoParamUseCase<String, GetAssistantContextFailure> {
  GetAssistantContextUseCase(this._getPortfolioUseCase);

  final GetPortfolioUseCase _getPortfolioUseCase;

  @protected
  @override
  FutureOr<Either<GetAssistantContextFailure, String>> execute() async {
    final result = await _getPortfolioUseCase();
    if (result.isLeft) {
      return Left(GetAssistantContextUnknownFailure(cause: result.left));
    }

    final portfolio = result.right;
    final profile = portfolio.profile;
    final today = DateTime.now();
    final availability = profile.availability;
    final hours = profile.workingHours;
    final location = profile.location;

    // One short line per record, so the model always sees every role, project,
    // skill group and service without relying on keyword retrieval.
    List<String> digest() {
      String list(List<String> items, [int max = 10]) =>
          items.take(max).join(', ');
      String store(Iterable<String?> urls) =>
          urls.any((url) => url != null && url.trim().isNotEmpty)
          ? 'yes'
          : 'no';
      final profile = portfolio.profile;
      return [
        '${profile.fullName}: ${profile.title}. Email: ${profile.email}. Phone: ${profile.phone}. Based in ${profile.location.city}, ${profile.location.country}.',
        for (final item in portfolio.experiences)
          '${_employmentSummary(item, today)} Location: ${item.location}. ${item.employmentType}. Technologies: ${list(item.technologies)}.',
        for (final item in portfolio.projects)
          'Project ${item.title} (${item.category}, ${item.status}, ${_date(item.startDate).substring(0, 4)}): ${list(item.technologies, 8)}. On Play Store: ${store(item.markets.map((market) => market.playStore))}. On App Store: ${store(item.markets.map((market) => market.appStore))}. Website: ${store(item.markets.map((market) => market.website))}. GitHub: ${store(item.markets.map((market) => market.github))}.${item.markets.isEmpty ? '' : ' Offered in: ${item.markets.map((market) => market.country).join(', ')}.'}',
        for (final item in portfolio.expertises)
          'Skills in ${item.title}: ${list(item.skillNames, 15)}.',
        for (final item in portfolio.services) 'Service: ${item.title}.',
      ];
    }

    return Right(
      jsonEncode({
        'asOf': _date(today),
        'overview': [
          ..._careerOverview(portfolio.experiences, today),
          ?_education([
            for (final item in profile.educations)
              '${item.degree}${item.field.isEmpty ? '' : ' in ${item.field}'} at ${item.institution}${item.location.isEmpty ? '' : ', ${item.location}'} (${item.startDate} to ${item.endDate})',
          ]),
          ?_languages([
            for (final item in profile.languages)
              '${item.language} (${item.proficiency})',
          ]),
        ],
        'digest': digest(),
        'profile': {
          'name': profile.fullName,
          'title': profile.title,
          'subtitle': profile.subtitle,
          'email': profile.email,
          'phone': profile.phone,
          'profileImage': profile.profileImage,
          'profileImages': profile.profileImages,
          'coverImage': profile.coverImage,
          'summary': profile.summary,
          'detailedBio': profile.detailedBio,
          'elevatorPitch': profile.elevatorPitch,
          'uniqueValueProposition': profile.uniqueValueProposition,
          'currentRole': profile.currentRole,
          'currentCompany': profile.currentCompany,
          'yearsOfExperience': profile.yearsOfExperience,
          'projectsDelivered': profile.projectsDelivered,
          'resume': {
            'url': profile.resume.url,
            'lastUpdated': profile.resume.lastUpdated,
            'image': profile.resume.image,
          },
          'availability': {
            'status': availability.status,
            'workType': availability.workType,
            'openToRelocate': availability.openToRelocate,
            'preferredProjectDuration': availability.preferredProjectDuration,
            'hourlyRate': availability.hourlyRate,
            'availability': availability.availability,
            'noticePeriod': ?availability.noticePeriod,
            'workAuthorization': ?availability.workAuthorization,
            'note': ?availability.note,
          },
          'workingHours': {
            'timezone': hours.timezone,
            'preferredHours': hours.preferredHours,
            'weekdays': hours.weekdays,
            'weekends': hours.weekends,
          },
          'location': {
            'city': location.city,
            'state': location.state,
            'country': location.country,
            'timezone': location.timezone,
            'latitude': location.coordinates.latitude,
            'longitude': location.coordinates.longitude,
          },
          'languages': [
            for (final item in profile.languages)
              {'language': item.language, 'proficiency': item.proficiency},
          ],
          'educations': [
            for (final item in profile.educations)
              {
                'institution': item.institution,
                'degree': item.degree,
                'field': item.field,
                'startDate': item.startDate,
                'endDate': item.endDate,
                'location': item.location,
                'url': item.url,
                'image': item.image,
              },
          ],
          'certifications': [
            for (final item in profile.certifications)
              {
                'name': item.name,
                'issuer': item.issuer,
                'date': item.date,
                'url': item.url,
              },
          ],
          'socialLinks': [
            for (final item in profile.socialLinks)
              {'name': item.name, 'url': item.url, 'image': item.image},
          ],
          'publishedAt': [
            for (final item in profile.publishedAt)
              {'name': item.name, 'url': item.url, 'image': item.image},
          ],
        },
        'experiences': [
          for (final item in portfolio.experiences)
            {
              'company': item.company,
              'position': item.position,
              'summary': _employmentSummary(item, today),
              'startDate': _date(item.startDate),
              'endDate': item.endDate == null ? null : _date(item.endDate!),
              'current': item.current,
              'location': item.location,
              'latitude': item.latitude,
              'longitude': item.longitude,
              'employmentType': item.employmentType,
              'description': item.description,
              'longDescription': item.longDescription,
              'responsibilities': item.responsibilities,
              'achievements': item.achievements,
              'technologies': item.technologies,
              'companyLogo': item.companyLogo,
              'url': item.url,
              'id': item.id,
              'projects': [
                for (final project in portfolio.projects)
                  if (project.experienceId == item.id)
                    {'id': project.id, 'title': project.title},
              ],
            },
        ],
        'projects': [
          for (final item in portfolio.projects)
            {
              'title': item.title,
              'links': _projectLinks(item),
              'description': item.description,
              'longDescription': item.longDescription,
              'technologies': item.technologies,
              'category': item.category,
              'status': item.status,
              'startDate': _date(item.startDate),
              'endDate': item.endDate == null ? null : _date(item.endDate!),
              'features': item.features,
              'achievements': item.achievements,
              'teamSize': item.teamSize,
              'role': item.role,
              'image': item.image,
              'id': item.id,
              'experienceId': item.experienceId,
              'experience': ?_experienceRef(portfolio, item.experienceId),
              if (item.markets.isNotEmpty)
                'markets': [
                  for (final market in item.markets)
                    {
                      'country': market.country,
                      'latitude': market.latitude,
                      'longitude': market.longitude,
                      'appStore': market.appStore,
                      'playStore': market.playStore,
                      'website': market.website,
                      'github': market.github,
                    },
                ],
              if (item.metrics.isNotEmpty)
                'metrics': [
                  for (final metric in item.metrics)
                    {'label': metric.label, 'value': metric.value},
                ],
            },
        ],
        'expertises': [
          for (final item in portfolio.expertises)
            {
              'title': item.title,
              'skills': [
                for (final skill in item.skills)
                  {
                    'name': skill.name,
                    'level': ?skill.level,
                    'years': ?skill.years,
                    'lastUsed': ?skill.lastUsed,
                  },
              ],
              'image': item.image,
            },
        ],
        'services': [
          for (final item in portfolio.services)
            {
              'title': item.title,
              'description': item.description,
              'detail': item.detail,
              'image': item.image,
              'id': item.id,
              'deliverables': item.deliverables,
              'technologies': item.technologies,
              'projects': [
                for (final project in portfolio.projects)
                  if (item.projectIds.contains(project.id))
                    {'id': project.id, 'title': project.title},
              ],
              'engagementTypes': item.engagementTypes,
              'idealFor': item.idealFor,
              'process': item.process,
              'faq': [
                for (final entry in item.faq)
                  {'question': entry.question, 'answer': entry.answer},
              ],
            },
        ],
        'testimonials': [
          for (final item in portfolio.testimonials)
            {
              'name': item.name,
              'position': item.position,
              'company': item.company,
              'testimonial': item.testimonial,
              'date': item.date,
              'projectContext': item.projectContext,
              'linkedinProfile': item.linkedinProfile,
              'profileImage': item.profileImage,
              'companyLogo': item.companyLogo,
              'id': item.id,
              'experienceId': item.experienceId,
              'experience': ?_experienceRef(portfolio, item.experienceId),
              'projects': [
                for (final project in portfolio.projects)
                  if (item.projectIds.contains(project.id) &&
                      project.experienceId == item.experienceId)
                    {'id': project.id, 'title': project.title},
              ],
            },
        ],
      }),
    );
  }

  static Map<String, String>? _experienceRef(
    PortfolioEntity portfolio,
    String? experienceId,
  ) {
    for (final item in portfolio.experiences) {
      if (item.id == experienceId) {
        return {'company': item.company, 'position': item.position};
      }
    }
    return null;
  }

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December', //
  ];

  static String _monthYear(DateTime date) =>
      '${_months[date.month - 1]} ${date.year}';

  // Whole months worked, counting the end date as a worked day, so July 1
  // through March 31 is 21 months and January 1 through March 1 is 2.
  static int? _tenureMonths(ExperienceEntity item, DateTime today) {
    final end = item.endDate ?? (item.current ? today : null);
    if (end == null) return null;
    final inclusiveEnd = DateTime(end.year, end.month, end.day + 1);
    final start = item.startDate;
    final months =
        (inclusiveEnd.year - start.year) * 12 +
        inclusiveEnd.month -
        start.month -
        (inclusiveEnd.day < start.day ? 1 : 0);
    return months < 1 ? 1 : months;
  }

  static String _formatMonths(int months) {
    final years = months ~/ 12;
    final rest = months % 12;
    final parts = [
      if (years > 0) '$years ${years == 1 ? 'year' : 'years'}',
      if (rest > 0) '$rest ${rest == 1 ? 'month' : 'months'}',
    ];
    return parts.join(' and ');
  }

  static String _range(ExperienceEntity item) {
    final end = item.endDate;
    return '${_monthYear(item.startDate)} to '
        '${end == null ? 'present' : _monthYear(end)}';
  }

  // A small model garbles numbers it must reformat, so the whole answer is
  // written out as one sentence with the duration already computed.
  static String _employmentSummary(ExperienceEntity item, DateTime today) {
    final months = _tenureMonths(item, today);
    if (months == null) {
      return 'Worked as ${item.position} at ${item.company} from '
          '${_monthYear(item.startDate)}; the end date is not provided.';
    }
    return 'Worked as ${item.position} at ${item.company} from '
        '${_range(item)}. Total time at ${item.company}: '
        '${_formatMonths(months)}.';
  }

  // Comparisons ("shortest", "longest", "how many") cannot be answered by
  // retrieving individual records, and a small model cannot rank eight jobs
  // reliably, so the rankings are computed here and stated outright.
  static List<String> _careerOverview(
    List<ExperienceEntity> experiences,
    DateTime today,
  ) {
    final dated = [
      for (final item in experiences)
        if (_tenureMonths(item, today) case final months?) (item, months),
    ]..sort((shorter, longer) => shorter.$2.compareTo(longer.$2));
    if (dated.isEmpty) return const [];

    String describe((ExperienceEntity, int) entry) =>
        '${entry.$1.company} (${entry.$1.position}), ${_range(entry.$1)}, '
        '${_formatMonths(entry.$2)}';

    final firstRole = dated.reduce(
      (earlier, later) =>
          earlier.$1.startDate.isBefore(later.$1.startDate) ? earlier : later,
    );
    final companies = {for (final item in experiences) item.company};
    final current = experiences.where((item) => item.current).toList();
    final counts =
        '${experiences.length} ${experiences.length == 1 ? 'role' : 'roles'} '
        'at ${companies.length} '
        '${companies.length == 1 ? 'company' : 'different companies'}';
    final currentRole = current.isEmpty
        ? null
        : 'Current role: ${current.first.position} at '
              '${current.first.company} since '
              '${_monthYear(current.first.startDate)}.';
    final ranking = dated.map(describe).join('; ');
    final timeline =
        ([...dated]..sort(
              (earlier, later) =>
                  earlier.$1.startDate.compareTo(later.$1.startDate),
            ))
            .map((entry) {
              final country = _country(entry.$1.location);
              final text = describe(entry);
              return country == null ? text : '$text, located in $country';
            })
            .join('; ');
    final countries = _countryTotals(experiences, today);
    // Short, frequently asked lines come first so a size budget drops the
    // long lists rather than these.
    return [
      'Career overview: $counts.',
      ?_totalExperience(experiences, today),
      'Shortest role: ${describe(dated.first)}.',
      'Longest role: ${describe(dated.last)}.',
      'First role (earliest start): ${describe(firstRole)}.',
      ?currentRole,
      ?_companyTotals(experiences, today),
      ?countries,
      ?_citySummary(experiences, today),
      ?_workModes(experiences),
      ?_careerGaps(experiences, today),
      ?_leadership(experiences, today),
      'All roles in chronological order, to answer questions about a year or period: $timeline.',
      'All roles from shortest to longest: $ranking.',
      ?_technologyTotals(experiences, today),
    ];
  }

  // Overlapping roles count each calendar month once, so the total is the
  // span actually worked rather than the sum of the roles.
  static String? _totalExperience(
    List<ExperienceEntity> experiences,
    DateTime today,
  ) {
    final covered = {for (final item in experiences) ..._monthSet(item, today)};
    if (covered.isEmpty) return null;
    final firstMonth = covered.reduce(
      (earlier, later) => earlier < later ? earlier : later,
    );
    final start = DateTime((firstMonth - 1) ~/ 12, (firstMonth - 1) % 12 + 1);
    final hasCurrentRole = experiences.any((item) => item.current);
    final end = hasCurrentRole
        ? 'present'
        : _monthYear(
            experiences
                .map((item) => item.endDate)
                .whereType<DateTime>()
                .reduce(
                  (earlier, later) => earlier.isAfter(later) ? earlier : later,
                ),
          );
    return 'Total professional experience: ${_formatMonths(covered.length)} '
        '(${_monthYear(start)} to $end), overlapping roles counted once.';
  }

  // A company with several roles ("how long at X?") needs one total, which
  // neither the per-role summaries nor a small model can add up reliably.
  // A single role keeps its own tenure so the total matches the role's line.
  static String? _companyTotals(
    List<ExperienceEntity> experiences,
    DateTime today,
  ) {
    final rolesByCompany = <String, List<ExperienceEntity>>{};
    for (final item in experiences) {
      if (_tenureMonths(item, today) == null) continue;
      rolesByCompany.putIfAbsent(item.company, () => []).add(item);
    }
    if (rolesByCompany.isEmpty) return null;
    final entries = rolesByCompany.entries.map((entry) {
      final roles = entry.value;
      final months = roles.length == 1
          ? _tenureMonths(roles.single, today)!
          : {for (final item in roles) ..._monthSet(item, today)}.length;
      final described = roles.map(
        (item) => '${item.position}, ${_range(item)}',
      );
      return '${entry.key}: ${_formatMonths(months)} in '
          '${roles.length} ${roles.length == 1 ? 'role' : 'roles'} '
          '(${described.join('; ')})';
    });
    return 'Time per company, overlapping roles counted once: '
        '${entries.join('. ')}.';
  }

  // Country names in project titles are markets, not spoken languages, so
  // the spoken languages are stated outright.
  static String? _education(List<String> educations) {
    if (educations.isEmpty) return null;
    return 'Education: ${educations.join('; ')}.';
  }

  static String? _languages(List<String> languages) {
    if (languages.isEmpty) return null;
    return 'Spoken languages (${languages.length}): ${languages.join(', ')}. '
        'No other spoken languages are listed.';
  }

  // "Barcelona, Spain [Remote]" -> a count per bracketed tag such as Remote.
  static String? _workModes(List<ExperienceEntity> experiences) {
    final companiesByMode = <String, List<String>>{};
    for (final item in experiences) {
      final tag = RegExp(r'\[(.*?)\]').firstMatch(item.location)?.group(1);
      if (tag == null || tag.trim().isEmpty) continue;
      companiesByMode
          .putIfAbsent(tag.trim(), () => [])
          .add('${item.company} (${item.position})');
    }
    if (companiesByMode.isEmpty) return null;
    final entries = companiesByMode.entries.map(
      (entry) =>
          '${entry.key}: ${entry.value.length} '
          '${entry.value.length == 1 ? 'role' : 'roles'} '
          '(${entry.value.join(', ')})',
    );
    return 'Roles by work mode (remote, freelance, ...), the others are '
        'on-site: ${entries.join('; ')}.';
  }

  static Set<int> _monthSet(ExperienceEntity item, DateTime today) {
    final end = item.endDate ?? (item.current ? today : null);
    if (end == null) return {};
    return {
      for (
        var month = item.startDate.year * 12 + item.startDate.month;
        month <= end.year * 12 + end.month;
        month++
      )
        month,
    };
  }

  // Skill durations ("how many years of Flutter?") come from the
  // technologies listed per role, counting overlapping roles once. Every
  // technology is listed, so a question about a rarely used one is answered
  // from this line instead of being guessed.
  static String? _technologyTotals(
    List<ExperienceEntity> experiences,
    DateTime today,
  ) {
    final monthsByTechnology = <String, Set<int>>{};
    for (final item in experiences) {
      final months = _monthSet(item, today);
      for (final technology in item.technologies) {
        final name = technology.trim();
        if (name.isNotEmpty) {
          monthsByTechnology.putIfAbsent(name, () => {}).addAll(months);
        }
      }
    }
    final ranked =
        monthsByTechnology.entries
            .where((entry) => entry.value.isNotEmpty)
            .toList()
          ..sort(
            (longer, shorter) =>
                shorter.value.length.compareTo(longer.value.length),
          );
    if (ranked.isEmpty) return null;
    final entries = ranked.map(
      (entry) => '${entry.key}: ${_formatMonths(entry.value.length)}',
    );
    return 'Time using each technology across all roles, overlapping roles '
        'counted once (technologies listed on the roles): '
        '${entries.join('; ')}.';
  }

  // A gap is a calendar month with no role in the span of the career.
  static String? _careerGaps(
    List<ExperienceEntity> experiences,
    DateTime today,
  ) {
    final covered = {for (final item in experiences) ..._monthSet(item, today)};
    if (covered.isEmpty) return null;
    final sorted = covered.toList()..sort();
    final gaps = <String>[];
    for (var index = 1; index < sorted.length; index++) {
      final missing = sorted[index] - sorted[index - 1] - 1;
      if (missing > 0) {
        final first = sorted[index - 1] + 1;
        final from = DateTime((first - 1) ~/ 12, (first - 1) % 12 + 1);
        gaps.add('${_formatMonths(missing)} starting ${_monthYear(from)}');
      }
    }
    final changes = experiences.length - 1;
    return gaps.isEmpty
        ? 'Career gaps: none, there is no month without a role. '
              'Job changes: $changes.'
        : 'Career gaps between roles: ${gaps.join('; ')}. '
              'Job changes: $changes.';
  }

  static String? _leadership(
    List<ExperienceEntity> experiences,
    DateTime today,
  ) {
    final leads = [
      for (final item in experiences)
        if (RegExp(
          r'\b(lead|manager|head)\b',
          caseSensitive: false,
        ).hasMatch(item.position))
          '${item.position} at ${item.company} (${_range(item)})',
    ];
    if (leads.isEmpty) return null;
    return 'Leadership roles: ${leads.join('; ')}.';
  }

  // Links are written out per market, with an explicit "not found" for
  // missing ones, so the model never has to hunt through null fields or
  // guess a URL, and no line is long enough to be cut inside a URL.
  static List<String> _projectLinks(ProjectEntity item) {
    if (item.markets.isEmpty) {
      return [
        'No store or website links are listed for the ${item.title} project.',
      ];
    }
    String link(String label, String? url) =>
        '$label: ${url == null || url.trim().isEmpty ? 'not found' : url}.';
    return item.markets
        .map(
          (market) =>
              'Links for the ${item.title} project in ${market.country}: '
              '${link('Play Store link', market.playStore)} '
              '${link('App Store link', market.appStore)} '
              '${link('Website', market.website)} '
              '${link('GitHub', market.github)}',
        )
        .toList();
  }

  // "Hyderabad, India [Remote]" -> "India".
  static String? _country(String location) {
    final parts = location
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty);
    return parts.isEmpty ? null : parts.last;
  }

  // "Hyderabad, India [Remote]" -> "Hyderabad". Overlapping roles in one city
  // count each calendar month once.
  static String? _citySummary(
    List<ExperienceEntity> experiences,
    DateTime today,
  ) {
    final months = <String, Set<int>>{};
    final roles = <String, List<String>>{};
    for (final item in experiences) {
      final parts = item.location.replaceAll(RegExp(r'\[.*?\]'), '').split(',');
      final city = parts.first.trim();
      final end = item.endDate ?? (item.current ? today : null);
      if (parts.length < 2 || city.isEmpty || end == null) continue;
      final cityMonths = months.putIfAbsent(city, () => {});
      for (
        var month = item.startDate.year * 12 + item.startDate.month;
        month <= end.year * 12 + end.month;
        month++
      ) {
        cityMonths.add(month);
      }
      roles
          .putIfAbsent(city, () => [])
          .add('${item.company} (${item.position})');
    }
    if (months.isEmpty) return null;
    final entries = months.entries.map((entry) {
      final companies = roles[entry.key]!;
      return '${entry.key}: ${_formatMonths(entry.value.length)} in '
          '${companies.length} ${companies.length == 1 ? 'role' : 'roles'} '
          '(${companies.join(', ')})';
    });
    return 'Experience per city, with time worked and roles: '
        '${entries.join('; ')}.';
  }

  // Overlapping roles in one country count each calendar month once.
  static String? _countryTotals(
    List<ExperienceEntity> experiences,
    DateTime today,
  ) {
    final monthsByCountry = <String, Set<int>>{};
    final companiesByCountry = <String, Set<String>>{};
    for (final item in experiences) {
      final country = _country(item.location);
      final end = item.endDate ?? (item.current ? today : null);
      if (country == null || end == null) continue;
      final months = monthsByCountry.putIfAbsent(country, () => {});
      for (
        var month = item.startDate.year * 12 + item.startDate.month;
        month <= end.year * 12 + end.month;
        month++
      ) {
        months.add(month);
      }
      companiesByCountry.putIfAbsent(country, () => {}).add(item.company);
    }
    if (monthsByCountry.isEmpty) return null;
    final entries = monthsByCountry.entries.map(
      (entry) =>
          '${entry.key}: ${_formatMonths(entry.value.length)} '
          '(${companiesByCountry[entry.key]!.join(', ')})',
    );
    return 'Total time worked per country, overlapping roles counted once: '
        '${entries.join('; ')}.';
  }

  @protected
  @override
  GetAssistantContextFailure mapErrorToFailure(Object e, StackTrace st) =>
      GetAssistantContextUnknownFailure(cause: e);
}
