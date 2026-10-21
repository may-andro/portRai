import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_rate_limit/ai_rate_limit.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/_entity.dart';
import 'package:portrai/src/feature/cv_export/domain/repository/_repository.dart';
import 'package:portrai/src/feature/cv_export/domain/use_case/is_cv_tailoring_available_use_case.dart';
import 'package:use_case/use_case.dart';

sealed class TailorCvDocumentFailure extends BasicFailure {
  const TailorCvDocumentFailure({super.cause});
}

@Localizable('errorCvTailoringUnavailable')
class CvTailoringUnavailableFailure extends TailorCvDocumentFailure {
  const CvTailoringUnavailableFailure({super.cause});
}

@Localizable('errorCvTailoringQuota')
class CvTailoringQuotaFailure extends TailorCvDocumentFailure {
  const CvTailoringQuotaFailure({super.cause});
}

@Localizable('errorCvTailoringNetwork')
class CvTailoringNetworkFailure extends TailorCvDocumentFailure {
  const CvTailoringNetworkFailure({super.cause});
}

@Localizable('errorCvTailoringUnknown')
class UnknownTailorCvDocumentFailure extends TailorCvDocumentFailure {
  const UnknownTailorCvDocumentFailure({super.cause});
}

class TailorCvDocumentParam {
  const TailorCvDocumentParam({required this.document, required this.target});

  final CvDocumentEntity document;
  final CvTailoringTargetEntity target;
}

/// Tailors a CV for a job with one AI request from the quota. Only the
/// summary is rewritten; projects, skill groups and skills keep their content
/// and are reordered by relevance. Experience stays in date order.
@register
class TailorCvDocumentUseCase
    extends
        BaseUseCase<
          CvDocumentEntity,
          TailorCvDocumentParam,
          TailorCvDocumentFailure
        > {
  TailorCvDocumentUseCase(
    this._isCvTailoringAvailableUseCase,
    this._consumeAiRequestQuotaUseCase,
    this._cvTailoringRepository,
  );

  static const maxSummaryLength = 700;

  final IsCvTailoringAvailableUseCase _isCvTailoringAvailableUseCase;
  final ConsumeAiRequestQuotaUseCase _consumeAiRequestQuotaUseCase;
  final CvTailoringRepository _cvTailoringRepository;

  @protected
  @override
  Future<Either<TailorCvDocumentFailure, CvDocumentEntity>> execute(
    TailorCvDocumentParam param,
  ) async {
    final isAvailableEither = await _isCvTailoringAvailableUseCase();
    if (isAvailableEither.isLeft || !isAvailableEither.right) {
      return const Left(CvTailoringUnavailableFailure());
    }
    final consumeAiRequestQuotaEither = await _consumeAiRequestQuotaUseCase();
    // Only a used-up budget blocks tailoring; an unreadable request log does
    // not, and the backend quota still applies.
    if (consumeAiRequestQuotaEither.isLeft &&
        consumeAiRequestQuotaEither.left is AiRequestQuotaExceededFailure) {
      return Left(
        CvTailoringQuotaFailure(cause: consumeAiRequestQuotaEither.left),
      );
    }

    final tailoring = await _cvTailoringRepository.tailor(
      document: param.document,
      target: param.target,
    );
    return Right(_apply(param.document, tailoring));
  }

  CvDocumentEntity _apply(
    CvDocumentEntity document,
    CvTailoringEntity tailoring,
  ) {
    final summary = tailoring.summary.trim();
    final prioritizedSkills = {
      for (final skill in tailoring.prioritizedSkills) skill.toLowerCase(),
    };
    return CvDocumentEntity(
      fullName: document.fullName,
      title: document.title,
      summary: summary.isEmpty || summary.length > maxSummaryLength
          ? document.summary
          : summary,
      photoUrl: document.photoUrl,
      photoUrls: document.photoUrls,
      contacts: document.contacts,
      experiences: document.experiences,
      projects: _reorder(document.projects, tailoring.projectOrder),
      skillGroups: [
        for (final group in _reorder(
          document.skillGroups,
          tailoring.skillGroupOrder,
        ))
          CvSkillGroupEntity(
            title: group.title,
            skills: [
              ...group.skills.where(
                (skill) => prioritizedSkills.contains(skill.toLowerCase()),
              ),
              ...group.skills.where(
                (skill) => !prioritizedSkills.contains(skill.toLowerCase()),
              ),
            ],
          ),
      ],
      educations: document.educations,
      websiteUrl: document.websiteUrl,
      hasMoreExperiences: document.hasMoreExperiences,
    );
  }

  /// The items at [order] first, skipping unknown and repeated indexes, then
  /// the rest in their original order, so no item is lost or duplicated.
  static List<T> _reorder<T>(List<T> items, List<int> order) {
    final indexes = <int>{
      for (final index in order)
        if (index >= 0 && index < items.length) index,
    };
    return [
      for (final index in indexes) items[index],
      for (final (index, item) in items.indexed)
        if (!indexes.contains(index)) item,
    ];
  }

  @protected
  @override
  TailorCvDocumentFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => switch (error) {
    AiQuotaExceededException() => CvTailoringQuotaFailure(cause: error),
    AiNetworkException() ||
    AiTimeoutException() ||
    TimeoutException() => CvTailoringNetworkFailure(cause: error),
    AiConfigurationException() || AiUnsupportedLocationException() =>
      CvTailoringUnavailableFailure(cause: error),
    _ => UnknownTailorCvDocumentFailure(cause: error),
  };
}
