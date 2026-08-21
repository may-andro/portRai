import 'package:portrai/src/feature/project/domain/_domain.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/dto/_dto.dart';

extension ProjectEntityExtension on ProjectEntity {
  List<ProjectSectionDTO> get sections {
    return [
      IntroSectionDTO(this),
      OverviewSectionDTO(this),
      TechnologiesSectionDTO(this),
      AchievementsSectionDTO(this),
      KeyFeaturesSectionDTO(this),
      AvailabilitiesSectionDTO(this),
    ];
  }
}
