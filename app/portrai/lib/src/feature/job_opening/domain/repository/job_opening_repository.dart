import 'package:portrai/src/feature/job_opening/domain/entity/_entity.dart';

abstract class JobOpeningRepository {
  /// The openings stored for [userId], in no particular order.
  Future<List<JobOpeningEntity>> getJobOpenings(String userId);

  Future<JobOpeningEntity> getJobOpening({
    required String userId,
    required String id,
  });

  /// Whether the weekly run includes [userId]. False when the user has no
  /// document yet.
  Future<bool> isJobSearchEnabled(String userId);

  Future<void> setJobSearchEnabled({
    required String userId,
    required bool isEnabled,
  });
}
