import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/dto/_dto.dart';

@immutable
sealed class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

final class LoadingState extends ProjectState {
  const LoadingState();
}

final class LoadedState extends ProjectState {
  const LoadedState({
    required this.project,
    required this.sections,
    this.profile,
  });

  final ProjectEntity project;
  final List<ProjectSectionDTO> sections;
  final ProfileEntity? profile;

  @override
  List<Object?> get props => [project, sections, profile];

  ProjectSectionDTO get introSection {
    return sections.firstWhere((section) => section is IntroSectionDTO);
  }

  List<ScrollableProjectSectionDTO> get scrollableSections {
    return sections.whereType<ScrollableProjectSectionDTO>().toList();
  }
}
