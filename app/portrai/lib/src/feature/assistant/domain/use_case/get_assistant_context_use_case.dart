import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/assistant_failure.dart';
import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/portfolio/portfolio.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:use_case/use_case.dart';

@register
class GetAssistantContextUseCase
    extends BaseNoParamUseCase<String, AssistantFailure> {
  GetAssistantContextUseCase(this._getPortfolioUseCase);

  final GetPortfolioUseCase _getPortfolioUseCase;

  @protected
  @override
  FutureOr<Either<AssistantFailure, String>> execute() async {
    final result = await _getPortfolioUseCase();
    if (result.isLeft) {
      return Left(UnknownAssistantFailure(cause: result.left));
    }

    final portfolio = result.right;
    final profile = portfolio.profile;
    final today = DateTime.now();
    final availability = profile.availability;
    final hours = profile.workingHours;
    final location = profile.location;

    return Right(
      jsonEncode({
        'asOf': _date(today),
        'overview': [
          ..._careerOverview(portfolio.experiences, today),
          ?_languages([
            for (final item in profile.languages)
              '${item.language} (${item.proficiency})',
          ]),
        ],
        'profile': {
          'name': profile.fullName,
          'title': profile.title,
          'subtitle': profile.subtitle,
          'email': profile.email,
          'phone': profile.phone,
          'profileImage': profile.profileImage,
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
              'employmentType': item.employmentType,
              'description': item.description,
              'longDescription': item.longDescription,
              'responsibilities': item.responsibilities,
              'achievements': item.achievements,
              'technologies': item.technologies,
              'companyLogo': item.companyLogo,
              'url': item.url,
              'id': item.id,
            },
        ],
        'projects': [
          for (final item in portfolio.projects)
            {
              'title': item.title,
              'summary': _projectLinks(item),
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
              'appStore': item.appStore,
              'playStore': item.playStore,
              'website': item.website,
              'github': item.github,
              'image': item.image,
              'id': item.id,
            },
        ],
        'expertises': [
          for (final item in portfolio.expertises)
            {'title': item.title, 'skills': item.skills, 'image': item.image},
        ],
        'services': [
          for (final item in portfolio.services)
            {
              'title': item.title,
              'description': item.description,
              'detail': item.detail,
              'image': item.image,
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
            },
        ],
      }),
    );
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
    ]..sort((a, b) => a.$2.compareTo(b.$2));
    if (dated.isEmpty) return const [];

    String describe((ExperienceEntity, int) entry) =>
        '${entry.$1.company} (${entry.$1.position}), ${_range(entry.$1)}, '
        '${_formatMonths(entry.$2)}';

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
        ([...dated]..sort((a, b) => a.$1.startDate.compareTo(b.$1.startDate)))
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
      'Shortest role: ${describe(dated.first)}.',
      'Longest role: ${describe(dated.last)}.',
      ?currentRole,
      ?countries,
      ?_workModes(experiences),
      ?_technologyTotals(experiences, today),
      ?_careerGaps(experiences, today),
      ?_leadership(experiences, today),
      'All roles in chronological order, to answer questions about a year or period: $timeline.',
      'All roles from shortest to longest: $ranking.',
    ];
  }

  // Country names in project titles are markets, not spoken languages, so
  // the spoken languages are stated outright.
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
  // technologies listed per role, counting overlapping roles once.
  static String? _technologyTotals(
    List<ExperienceEntity> experiences,
    DateTime today,
  ) {
    final monthsByTech = <String, Set<int>>{};
    for (final item in experiences) {
      final months = _monthSet(item, today);
      for (final tech in item.technologies) {
        final name = tech.trim();
        if (name.isNotEmpty) {
          monthsByTech.putIfAbsent(name, () => {}).addAll(months);
        }
      }
    }
    final ranked =
        monthsByTech.entries.where((entry) => entry.value.length >= 12).toList()
          ..sort((a, b) => b.value.length.compareTo(a.value.length));
    if (ranked.isEmpty) return null;
    final entries = ranked
        .take(12)
        .map((entry) => '${entry.key}: ${_formatMonths(entry.value.length)}');
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
        final from = DateTime(first ~/ 12, first % 12 == 0 ? 12 : first % 12);
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

  // Links are written out, with an explicit "not found" for missing ones, so
  // the model never has to hunt through null fields or guess a URL.
  static String _projectLinks(ProjectEntity item) {
    String link(String label, String? url) =>
        '$label: ${url == null || url.trim().isEmpty ? 'not found' : url}';
    return 'Links for the ${item.title} project. '
        '${link('Play Store link', item.playStore)}. '
        '${link('App Store link', item.appStore)}. '
        '${link('Website', item.website)}. '
        '${link('GitHub', item.github)}.';
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
  AssistantFailure mapErrorToFailure(Object e, StackTrace st) =>
      UnknownAssistantFailure(cause: e);
}
