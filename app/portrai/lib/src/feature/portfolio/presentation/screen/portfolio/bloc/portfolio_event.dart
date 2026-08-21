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

final class ScreenVisibleEvent extends PortfolioEvent {
  const ScreenVisibleEvent();
}

final class ViewStateVisibleEvent extends PortfolioEvent {
  const ViewStateVisibleEvent(this.trackingId);

  factory ViewStateVisibleEvent.loading() {
    return const ViewStateVisibleEvent('loading_content_view');
  }

  factory ViewStateVisibleEvent.success() {
    return const ViewStateVisibleEvent('loaded_content_view');
  }

  factory ViewStateVisibleEvent.error() {
    return const ViewStateVisibleEvent('error_content_view');
  }

  final String trackingId;
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
