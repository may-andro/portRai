import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class PortfolioEvent extends Equatable {
  const PortfolioEvent();

  @override
  List<Object> get props => [];
}

class LoadPortfolioEvent extends PortfolioEvent {
  const LoadPortfolioEvent();
}

/// An update refreshed cached sections, so the shown portfolio may be outdated.
final class PortfolioSectionsRefreshedEvent extends PortfolioEvent {
  const PortfolioSectionsRefreshedEvent();
}

final class ScreenVisibleEvent extends PortfolioEvent {
  const ScreenVisibleEvent();
}

final class ViewStateVisibleEvent extends PortfolioEvent {
  const ViewStateVisibleEvent(this.trackingId);

  final String trackingId;

  @override
  List<Object> get props => [trackingId];
}

final class SectionVisibleEvent extends PortfolioEvent {
  const SectionVisibleEvent(this.trackingId);

  final String trackingId;

  @override
  List<Object> get props => [trackingId];
}

final class DrawerClickEvent extends PortfolioEvent {
  const DrawerClickEvent(this.isOpened);

  final bool isOpened;

  @override
  List<Object> get props => [isOpened];
}

final class SectionNavigationEvent extends PortfolioEvent {
  const SectionNavigationEvent({
    required this.sectionIndex,
    required this.sectionId,
    required this.source,
  });

  final int sectionIndex;
  final String sectionId;
  final NavigationSource source;

  @override
  List<Object> get props => [sectionIndex, sectionId, source];
}

enum NavigationSource { drawer, header, scroll }

final class AssistantLaunchClickEvent extends PortfolioEvent {
  const AssistantLaunchClickEvent({required this.isLocal});

  final bool isLocal;

  @override
  List<Object> get props => [isLocal];
}

/// A section whose full list opens from its See all button.
enum SeeAllSection { expertises, services, experiences, testimonials }

final class SeeAllClickEvent extends PortfolioEvent {
  const SeeAllClickEvent(this.section);

  final SeeAllSection section;

  @override
  List<Object> get props => [section];
}

final class SettingClickEvent extends PortfolioEvent {
  const SettingClickEvent();
}

final class ExperienceClickEvent extends PortfolioEvent {
  const ExperienceClickEvent(this.experienceId);

  final String experienceId;

  @override
  List<Object> get props => [experienceId];
}

final class ExpertiseClickEvent extends PortfolioEvent {
  const ExpertiseClickEvent(this.expertiseTitle);

  final String expertiseTitle;

  @override
  List<Object> get props => [expertiseTitle];
}

final class ServiceClickEvent extends PortfolioEvent {
  const ServiceClickEvent(this.serviceTitle);

  final String serviceTitle;

  @override
  List<Object> get props => [serviceTitle];
}

final class ProjectClickEvent extends PortfolioEvent {
  const ProjectClickEvent(this.projectId);

  final String projectId;

  @override
  List<Object> get props => [projectId];
}

final class ProfileClickEvent extends PortfolioEvent {
  const ProfileClickEvent();
}
