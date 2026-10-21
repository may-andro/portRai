import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_rate_limit/ai_rate_limit.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/ai_rate_limit/domain/use_case/mock_consume_ai_request_quota_use_case.dart';
import '../../../../../mock/feature/cv_export/domain/repository/mock_cv_tailoring_repository.dart';
import '../../../../../mock/feature/cv_export/domain/use_case/mock_is_cv_tailoring_available_use_case.dart';
import '../../../../../util/cv_export_test_fixture.dart';

void main() {
  group('TailorCvDocumentUseCase', () {
    late MockIsCvTailoringAvailableUseCase isCvTailoringAvailableUseCase;
    late MockConsumeAiRequestQuotaUseCase consumeAiRequestQuotaUseCase;
    late MockCvTailoringRepository cvTailoringRepository;
    late TailorCvDocumentUseCase useCase;

    final document = CvExportTestFixture.heavyDocument();
    const target = CvTailoringTargetEntity(
      title: 'Senior Flutter Developer',
      company: 'Acme',
      description: 'Build apps with Flutter.',
    );
    final documentParam = TailorCvDocumentParam(
      document: document,
      target: target,
    );

    void stubTailoring(CvTailoringEntity tailoring) {
      when(
        () => cvTailoringRepository.tailor(
          document: any(named: 'document'),
          target: any(named: 'target'),
        ),
      ).thenAnswer((_) async => tailoring);
    }

    setUpAll(() {
      registerFallbackValue(document);
      registerFallbackValue(target);
    });

    setUp(() {
      isCvTailoringAvailableUseCase = MockIsCvTailoringAvailableUseCase()
        ..stubCall(const Right(true));
      consumeAiRequestQuotaUseCase = MockConsumeAiRequestQuotaUseCase()
        ..stubCall(const Right(null));
      cvTailoringRepository = MockCvTailoringRepository();
      useCase = TailorCvDocumentUseCase(
        isCvTailoringAvailableUseCase,
        consumeAiRequestQuotaUseCase,
        cvTailoringRepository,
      );
    });

    test('should rewrite the summary and reorder projects and skills when '
        'tailored', () async {
      stubTailoring(
        const CvTailoringEntity(
          summary: 'Flutter engineer who ships apps.',
          projectOrder: [2, 0],
          skillGroupOrder: [3],
          prioritizedSkills: ['skill 5', 'Unknown'],
        ),
      );

      final result = await useCase(documentParam);

      final tailored = result.right;
      expect(tailored.summary, 'Flutter engineer who ships apps.');
      expect(tailored.projects.map((project) => project.title), [
        'Project 2',
        'Project 0',
        'Project 1',
        'Project 3',
        'Project 4',
        'Project 5',
      ]);
      expect(tailored.skillGroups.first.title, 'Group 3');
      expect(tailored.skillGroups, hasLength(document.skillGroups.length));
      expect(tailored.skillGroups.first.skills.first, 'Skill 5');
      expect(
        tailored.skillGroups.first.skills,
        hasLength(document.skillGroups.first.skills.length),
      );
      expect(tailored.experiences, document.experiences);
      expect(tailored.contacts, document.contacts);
      expect(tailored.educations, document.educations);
      verify(() => consumeAiRequestQuotaUseCase()).called(1);
    });

    test('should skip unknown and repeated indexes without losing '
        'items', () async {
      stubTailoring(
        const CvTailoringEntity(
          summary: 'Summary.',
          projectOrder: [9, -1, 1, 1],
        ),
      );

      final result = await useCase(documentParam);

      expect(result.right.projects.map((project) => project.title), [
        'Project 1',
        'Project 0',
        'Project 2',
        'Project 3',
        'Project 4',
        'Project 5',
      ]);
    });

    test('should keep the original summary when the new one is empty or too '
        'long', () async {
      stubTailoring(const CvTailoringEntity(summary: '  '));
      expect((await useCase(documentParam)).right.summary, document.summary);

      stubTailoring(
        CvTailoringEntity(
          summary: 'a' * (TailorCvDocumentUseCase.maxSummaryLength + 1),
        ),
      );
      expect((await useCase(documentParam)).right.summary, document.summary);
    });

    test('should fail as unavailable without a request when tailoring is '
        'off', () async {
      isCvTailoringAvailableUseCase.stubCall(const Right(false));

      final result = await useCase(documentParam);

      expect(result.left, isA<CvTailoringUnavailableFailure>());
      verifyNever(() => consumeAiRequestQuotaUseCase());
    });

    test('should fail on quota without a request when the budget is used '
        'up', () async {
      consumeAiRequestQuotaUseCase.stubCall(
        const Left(AiRequestQuotaExceededFailure()),
      );

      final result = await useCase(documentParam);

      expect(result.left, isA<CvTailoringQuotaFailure>());
      verifyNever(
        () => cvTailoringRepository.tailor(
          document: any(named: 'document'),
          target: any(named: 'target'),
        ),
      );
    });

    test('should still tailor when the request log cannot be read', () async {
      consumeAiRequestQuotaUseCase.stubCall(
        const Left(AiRequestQuotaCacheFailure()),
      );
      stubTailoring(const CvTailoringEntity(summary: 'Summary.'));

      final result = await useCase(documentParam);

      expect(result.right.summary, 'Summary.');
    });

    for (final (error, failureType) in [
      (
        AiQuotaExceededException(Exception(), StackTrace.empty),
        CvTailoringQuotaFailure,
      ),
      (
        AiNetworkException(Exception(), StackTrace.empty),
        CvTailoringNetworkFailure,
      ),
      (TimeoutException('slow'), CvTailoringNetworkFailure),
      (
        const CvTailoringResponseException('bad'),
        UnknownTailorCvDocumentFailure,
      ),
    ]) {
      test('should map ${error.runtimeType} to $failureType', () async {
        when(
          () => cvTailoringRepository.tailor(
            document: any(named: 'document'),
            target: any(named: 'target'),
          ),
        ).thenThrow(error);

        final result = await useCase(documentParam);

        expect(result.left.runtimeType, failureType);
      });
    }
  });
}
