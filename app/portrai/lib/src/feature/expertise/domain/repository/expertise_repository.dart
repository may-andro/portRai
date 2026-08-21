import 'package:portrai/src/feature/expertise/domain/entity/_entity.dart';

abstract class ExpertiseRepository {
  Future<List<ExpertiseEntity>> getAllExpertise();

  Future<void> cacheExpertise(ExpertiseEntity expert);
}
