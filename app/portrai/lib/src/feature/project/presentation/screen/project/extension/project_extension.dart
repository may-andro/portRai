import 'package:portrai/src/feature/project/domain/_domain.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/dto/_dto.dart';

extension ProjectEntityExtension on ProjectEntity {
  List<ProjectSectionDTO> get sections {
    return [
      IntroSectionDTO(this),
      OverviewSectionDTO(this),
      KeyFeaturesSectionDTO(this),
      TechnologiesSectionDTO(this),
      AchievementsSectionDTO(this),
      if (markets.isNotEmpty) MarketsSectionDTO(this),
      AvailabilitiesSectionDTO(this),
    ];
  }
}
