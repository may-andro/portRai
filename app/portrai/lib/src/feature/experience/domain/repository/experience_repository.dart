import 'package:portrai/src/feature/experience/domain/entity/_entity.dart';

abstract class ExperienceRepository {
  Future<ExperienceEntity> getExperience(String id);

  Future<List<ExperienceEntity>> getExperiences();

  Future<void> cacheExperience(ExperienceEntity experience);
}
