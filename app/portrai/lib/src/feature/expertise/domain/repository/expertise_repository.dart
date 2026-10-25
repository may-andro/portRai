import 'package:portrai/src/feature/expertise/domain/entity/_entity.dart';

abstract class ExpertiseRepository {
  Future<List<ExpertiseEntity>> getAllExpertise();

  Future<void> cacheAllExpertise(List<ExpertiseEntity> expertiseList);

  /// Replaces the cached expertise of the current locale with the latest one.
  Future<void> refreshAllExpertise();
}
