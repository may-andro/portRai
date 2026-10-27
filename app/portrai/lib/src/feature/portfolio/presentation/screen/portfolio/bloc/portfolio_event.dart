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

final class SeeAllClickEvent extends PortfolioEvent {
  const SeeAllClickEvent({required this.label, required this.sectionName});

  /// The tapped element, such as a button or card.
  final String label;

  /// The section whose full list opens.
  final String sectionName;

  @override
  List<Object> get props => [label, sectionName];
}

final class SettingClickEvent extends PortfolioEvent {
  const SettingClickEvent(this.label);

  /// The tapped element, such as a button or card.
  final String label;

  @override
  List<Object> get props => [label];
}
