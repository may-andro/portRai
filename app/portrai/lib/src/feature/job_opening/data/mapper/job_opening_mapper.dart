import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/job_opening/data/model/_model.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';

/// Maps one direction only: the app reads openings but never writes them.
@register
class JobOpeningMapper implements Mapper<JobOpeningModel, JobOpeningEntity> {
  const JobOpeningMapper();

  @override
  JobOpeningEntity map(JobOpeningModel from) => JobOpeningEntity(
    id: from.id,
    sourceName: from.sourceName,
    title: from.title,
    company: from.company,
    url: Uri.parse(from.url),
    location: from.location,
    tags: from.tags,
    jobTypes: from.jobTypes,
    description: from.description,
    score: from.score.round().clamp(0, 100),
    matchedSkills: from.matchedSkills,
    missingSkills: from.missingSkills,
    reasons: from.reasons,
    publishedAt: from.publishedAt,
    fetchedAt: from.fetchedAt,
  );
}
