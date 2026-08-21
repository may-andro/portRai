import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/dto/_dto.dart';

@immutable
sealed class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

final class ScreenVisibleEvent extends ProjectEvent {}

final class LoadProjectEvent extends ProjectEvent {
  const LoadProjectEvent(this.project);

  final ProjectEntity project;

  @override
  List<Object?> get props => [project];
}

final class LoadingContentViewVisibleEvent extends ProjectEvent {
  const LoadingContentViewVisibleEvent();
}

final class SuccessContentViewVisibleEvent extends ProjectEvent {
  const SuccessContentViewVisibleEvent();
}

final class OpenExternalUrlEvent extends ProjectEvent {
  const OpenExternalUrlEvent({required this.url, required this.label});

  final String url;
  final String label;

  @override
  List<Object?> get props => [url, label];
}

final class HeaderTabClickEvent extends ProjectEvent {
  const HeaderTabClickEvent(this.section);

  final ScrollableProjectSectionDTO section;

  @override
  List<Object?> get props => [section];
}

final class SectionVisibleEvent extends ProjectEvent {
  const SectionVisibleEvent(this.trackingId);

  final String trackingId;

  @override
  List<Object?> get props => [trackingId];
}
