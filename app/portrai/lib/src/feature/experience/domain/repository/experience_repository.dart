import 'package:portrai/src/feature/experience/domain/entity/_entity.dart';

abstract class ExperienceRepository {
  Future<ExperienceEntity> getExperience(String id);

  Future<List<ExperienceEntity>> getExperiences();

  Future<void> cacheExperiences(List<ExperienceEntity> experiences);

  /// Replaces the cached experiences of the current locale with the latest
  /// ones.
  Future<void> refreshExperiences();
}
