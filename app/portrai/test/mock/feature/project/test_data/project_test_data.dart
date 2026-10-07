import 'package:portrai/src/feature/project/data/model/_model.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

ProjectEntity createProjectEntity({
  String id = 'port-rai',
  String title = 'PortRai 🚀',
  DateTime? endDate,
  bool hasEndDate = true,
  String? appStore = 'https://example.com/app-store',
  String? playStore = 'https://example.com/play-store',
  String? website = 'https://example.com/website',
  String? github = 'https://github.com/example/portrai',
}) {
  return ProjectEntity(
    id: id,
    title: title,
    description: 'A polished portfolio app',
    longDescription:
        'A polished portfolio app built with Flutter and modular architecture.',
    image: 'https://example.com/project.png',
    technologies: const ['Flutter', 'Dart'],
    category: 'Mobile App',
    status: 'active',
    startDate: DateTime(2024),
    endDate: hasEndDate ? endDate ?? DateTime(2025, 3) : null,
    appStore: appStore,
    playStore: playStore,
    website: website,
    github: github,
    features: const ['Localization', 'Tracking'],
    achievements: const ['Launched to production'],
    teamSize: 3,
    role: 'Lead Flutter Developer',
  );
}

ProjectModel createProjectModel({
  String locale = 'en',
  String id = 'port-rai',
  String title = 'PortRai 🚀',
  String? endDate = '2025-03-01T00:00:00.000',
  String? appStore = 'https://example.com/app-store',
  String? playStore = 'https://example.com/play-store',
  String? website = 'https://example.com/website',
  String? github = 'https://github.com/example/portrai',
}) {
  return ProjectModel(
    id: id,
    title: title,
    description: 'A polished portfolio app',
    longDescription:
        'A polished portfolio app built with Flutter and modular architecture.',
    image: 'https://example.com/project.png',
    technologies: const ['Flutter', 'Dart'],
    category: 'Mobile App',
    status: 'active',
    startDate: '2024-01-01T00:00:00.000',
    endDate: endDate,
    appStore: appStore,
    playStore: playStore,
    website: website,
    github: github,
    features: const ['Localization', 'Tracking'],
    achievements: const ['Launched to production'],
    teamSize: 3,
    role: 'Lead Flutter Developer',
    locale: locale,
  );
}

Map<String, dynamic> createProjectJson({
  String locale = 'en',
  String id = 'port-rai',
  String title = 'PortRai 🚀',
  String? endDate = '2025-03-01T00:00:00.000',
  String? appStore = 'https://example.com/app-store',
  String? playStore = 'https://example.com/play-store',
  String? website = 'https://example.com/website',
  String? github = 'https://github.com/example/portrai',
}) {
  return createProjectModel(
    locale: locale,
    id: id,
    title: title,
    endDate: endDate,
    appStore: appStore,
    playStore: playStore,
    website: website,
    github: github,
  ).toJson();
}

Map<String, dynamic> createProjectAssetJson({
  String locale = 'en',
  List<Map<String, dynamic>>? projects,
}) {
  return {
    locale: {
      'projects': projects ?? [createProjectJson(locale: locale)],
    },
  };
}

List<Map<String, dynamic>> createProjectListJson({String locale = 'en'}) {
  return [
    createProjectJson(locale: locale),
    createProjectJson(
      locale: locale,
      id: 'portfolio-admin',
      title: 'Portfolio Admin',
      website: null,
      github: null,
    ),
  ];
}
