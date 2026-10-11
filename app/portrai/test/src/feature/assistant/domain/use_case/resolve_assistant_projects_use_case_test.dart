import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/project/domain/use_case/mock_get_projects_use_case.dart';
import '../../../../../mock/feature/project/test_data/project_test_data.dart';

void main() {
  late MockGetProjectsUseCase getProjectsUseCase;
  late ResolveAssistantProjectsUseCase useCase;

  setUp(() {
    getProjectsUseCase = MockGetProjectsUseCase();
    useCase = ResolveAssistantProjectsUseCase(getProjectsUseCase);
  });

  group('ResolveAssistantProjectsUseCase', () {
    test(
      'should preserve source entities and order when IDs are valid',
      () async {
        final first = createProjectEntity(
          id: 'first',
          title: 'Localized first',
        );
        final second = createProjectEntity(id: 'second', website: null);
        final third = createProjectEntity(id: 'third');
        getProjectsUseCase.stubCall(Right([first, second, third]));

        final result = await useCase(['third', 'first', 'second']);

        expect(result.right, [third, first, second]);
        expect(result.right[0], same(third));
        expect(result.right[1], same(first));
        expect(result.right[2], same(second));
        verify(() => getProjectsUseCase()).called(1);
      },
    );

    test(
      'should return an immutable empty list when no IDs are given',
      () async {
        final result = await useCase([]);

        expect(result.right, isEmpty);
        expect(
          () => result.right.add(createProjectEntity()),
          throwsUnsupportedError,
        );
        verifyNever(() => getProjectsUseCase());
      },
    );

    test(
      'should reject excess IDs before loading when limit is exceeded',
      () async {
        final result = await useCase([
          for (var i = 0; i <= ResolveAssistantProjectsUseCase.maxProjects; i++)
            'project-$i',
        ]);

        expect(result.left, isA<AssistantProjectLimitExceededFailure>());
        verifyNever(() => getProjectsUseCase());
      },
    );

    for (final id in ['', ' ', '\t\n']) {
      test(
        'should reject a blank ID before loading when ID is "$id"',
        () async {
          final result = await useCase(['valid', id]);

          expect(result.left, isA<AssistantProjectInvalidIdFailure>());
          verifyNever(() => getProjectsUseCase());
        },
      );
    }

    test(
      'should reject repeated IDs before loading when input has duplicates',
      () async {
        final result = await useCase(['first', 'first']);

        expect(result.left, isA<AssistantProjectDuplicateIdFailure>());
        verifyNever(() => getProjectsUseCase());
      },
    );

    test('should reject the entire request when one ID is unknown', () async {
      getProjectsUseCase.stubCall(Right([createProjectEntity(id: 'first')]));

      final result = await useCase(['first', 'unknown']);

      expect(result.isRight, isFalse);
      expect(result.left, isA<AssistantProjectUnknownIdFailure>());
    });

    test('should reject unknown IDs when the source list is empty', () async {
      getProjectsUseCase.stubCall(const Right([]));

      final result = await useCase(['first']);

      expect(result.left, isA<AssistantProjectUnknownIdFailure>());
    });

    for (final id in ['First', ' first ']) {
      test('should match exactly when the requested ID is "$id"', () async {
        getProjectsUseCase.stubCall(Right([createProjectEntity(id: 'first')]));

        final result = await useCase([id]);

        expect(result.left, isA<AssistantProjectUnknownIdFailure>());
      });
    }

    test(
      'should reject ambiguous IDs when selected source records share an ID',
      () async {
        getProjectsUseCase.stubCall(
          Right([
            createProjectEntity(id: 'first'),
            createProjectEntity(id: 'first', title: 'Other first'),
          ]),
        );

        final result = await useCase(['first']);

        expect(result.left, isA<AssistantProjectAmbiguousIdFailure>());
      },
    );

    test(
      'should ignore source duplicates when their ID is not selected',
      () async {
        final selected = createProjectEntity(id: 'selected');
        getProjectsUseCase.stubCall(
          Right([
            createProjectEntity(id: 'other'),
            selected,
            createProjectEntity(id: 'other'),
          ]),
        );

        final result = await useCase(['selected']);

        expect(result.right.single, same(selected));
      },
    );

    test('should wrap the typed cause when source loading fails', () async {
      const failure = ProjectNetworkFailure();
      getProjectsUseCase.stubCall(const Left(failure));

      final result = await useCase(['first']);

      expect(result.left, isA<AssistantProjectsSourceFailure>());
      expect(result.left.cause, same(failure));
    });

    test(
      'should map a typed failure when the source unexpectedly throws it',
      () async {
        const failure = ProjectDataFailure();
        when(() => getProjectsUseCase()).thenThrow(failure);

        final result = await useCase(['first']);

        expect(result.left, isA<AssistantProjectsSourceFailure>());
        expect(result.left.cause, same(failure));
      },
    );

    test(
      'should map unknown errors when the source unexpectedly throws',
      () async {
        final error = StateError('unexpected');
        when(() => getProjectsUseCase()).thenThrow(error);

        final result = await useCase(['first']);

        expect(result.left, isA<ResolveAssistantProjectsUnknownFailure>());
        expect(result.left.cause, same(error));
      },
    );

    test(
      'should snapshot requested IDs when input changes during source loading',
      () async {
        final pending =
            Completer<Either<GetProjectsFailure, List<ProjectEntity>>>();
        when(() => getProjectsUseCase()).thenAnswer((_) => pending.future);
        final ids = ['first'];
        final first = createProjectEntity(id: 'first');

        final resolution = useCase(ids);
        ids[0] = 'unknown';
        pending.complete(Right([first]));
        final result = await resolution;

        expect(result.right.single, same(first));
      },
    );

    test(
      'should keep an immutable snapshot when source list changes after success',
      () async {
        final first = createProjectEntity(id: 'first');
        final source = [first];
        getProjectsUseCase.stubCall(Right(source));

        final result = await useCase(['first']);
        source.clear();

        expect(result.right.single, same(first));
        expect(() => result.right.clear(), throwsUnsupportedError);
        expect(
          () => result.right[0] = createProjectEntity(),
          throwsUnsupportedError,
        );
      },
    );
  });
}
