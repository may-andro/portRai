import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:portrai/src/feature/remote_assistant/domain/_domain.dart';
import 'package:portrai/src/utility/log_use_case_interceptor.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/project/domain/use_case/mock_get_projects_use_case.dart';
import '../../../../../mock/feature/project/test_data/project_test_data.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  late MockGetProjectsUseCase source;
  late ParseRemoteAssistantResponseUseCase useCase;

  setUp(() {
    source = MockGetProjectsUseCase();
    useCase = ParseRemoteAssistantResponseUseCase(
      ResolveAssistantProjectsUseCase(source),
    );
  });

  Future<
    Either<ParseRemoteAssistantResponseFailure, RemoteAssistantResponseEntity>
  >
  parse(String payload) async =>
      await useCase(ParseRemoteAssistantResponseParams(payload));

  String payload({
    Object? version = 1,
    Object? text = 'Answer',
    Object? ids = const [],
  }) => jsonEncode({'version': version, 'text': text, 'projectIds': ids});

  test(
    'should preserve source identity and order when three IDs resolve',
    () async {
      final projects = [
        for (final id in ['first', 'second', 'third'])
          createProjectEntity(id: id),
      ];
      source.stubCall(Right(projects));

      final result = await parse(
        payload(text: '  Answer\n', ids: ['third', 'first', 'second']),
      );

      expect(result.right.text, '  Answer\n');
      expect(result.right.projects, [projects[2], projects[0], projects[1]]);
      expect(result.right.projects.first, same(projects[2]));
      projects.clear();
      expect(result.right.projects, hasLength(3));
      expect(() => result.right.projects.clear(), throwsUnsupportedError);
      expect(
        () => result.right.projects[0] = createProjectEntity(),
        throwsUnsupportedError,
      );
      verify(() => source()).called(1);
    },
  );

  test('should snapshot projects when the DTO input list changes', () {
    final project = createProjectEntity();
    final projects = [project];
    final response = RemoteAssistantResponseEntity(
      text: 'Answer',
      projects: projects,
    );
    projects.clear();
    expect(response.projects.single, same(project));
    expect(() => response.projects.add(project), throwsUnsupportedError);
  });

  test(
    'should return only text without loading when references are empty',
    () async {
      final result = await parse(payload());
      expect(result.right.text, 'Answer');
      expect(result.right.projects, isEmpty);
      expect(
        () => result.right.projects.add(createProjectEntity()),
        throwsUnsupportedError,
      );
      verifyNever(() => source());
    },
  );

  final malformed = [
    '',
    '{"version":1,"text":"secret"',
    '```json\n{"version":1,"text":"Answer","projectIds":[]}\n```',
    '${payload()} trailing',
    'null',
    '[]',
    '"Answer"',
    '1',
    ...['version', 'text', 'projectIds'].map(
      (key) => jsonEncode(
        {'version': 1, 'text': 'Answer', 'projectIds': <String>[]}..remove(key),
      ),
    ),
    jsonEncode({
      'version': 1,
      'text': 'Answer',
      'projectIds': <String>[],
      'action': 'https://untrusted.example',
    }),
    ...[
      null,
      42,
      true,
      <Object?>[],
      <String, Object?>{},
      '',
      ' \t\n',
    ].map((text) => payload(text: text)),
    ...[
      null,
      'first',
      1,
      <String, Object?>{},
      [1],
      [null],
      [true],
      [<String, Object?>{}],
    ].map((ids) => payload(ids: ids)),
  ];
  for (var i = 0; i < malformed.length; i++) {
    test(
      'should reject without loading when JSON or shape is invalid (case $i)',
      () async {
        final result = await parse(malformed[i]);
        expect(result.left, isA<RemoteAssistantResponseInvalidFailure>());
        expect(result.left.cause, isNull);
        verifyNever(() => source());
      },
    );
  }

  for (final version in [
    null,
    true,
    false,
    '1',
    1.0,
    1.5,
    0,
    2,
    <Object?>[],
    <String, Object?>{},
  ]) {
    test('should reject without loading when version is $version', () async {
      final result = await parse(payload(version: version));
      expect(result.left, isA<RemoteAssistantResponseVersionFailure>());
      verifyNever(() => source());
    });
  }
  test(
    'should reject a floating token without loading when version is exponential',
    () async {
      final result = await parse(
        '{"version":1e0,"text":"Answer","projectIds":[]}',
      );
      expect(result.left, isA<RemoteAssistantResponseVersionFailure>());
      verifyNever(() => source());
    },
  );

  test(
    'should accept the exact bound when payload is within the limit',
    () async {
      final padding =
          RemoteAssistantRequestLimits.maxResponseCharacters -
          payload(text: '').length;
      final result = await parse(payload(text: 'a' * padding));
      expect(result.right.text, hasLength(padding));
      verifyNever(() => source());
    },
  );
  for (final oversized in [
    ' ' * (RemoteAssistantRequestLimits.maxResponseCharacters + 1),
    payload(
      text: 'a' * (RemoteAssistantRequestLimits.maxResponseCharacters + 1),
    ),
  ]) {
    test(
      'should reject without loading when payload or text exceeds bounds (${oversized.length})',
      () async {
        final result = await parse(oversized);
        expect(result.left, isA<RemoteAssistantResponseSizeFailure>());
        verifyNever(() => source());
      },
    );
  }

  for (final entry in <(List<String>, ResolveAssistantProjectsFailure)>[
    (['a', 'b', 'c', 'd'], const AssistantProjectLimitExceededFailure()),
    ([''], const AssistantProjectInvalidIdFailure()),
    ([' \t\n'], const AssistantProjectInvalidIdFailure()),
    (['first', 'first'], const AssistantProjectDuplicateIdFailure()),
  ]) {
    test(
      'should propagate ${entry.$2.runtimeType} without loading when IDs are invalid',
      () async {
        final result = await parse(payload(ids: entry.$1));
        expect(result.left, isA<RemoteAssistantResponseResolutionFailure>());
        expect(result.left.cause, entry.$2);
        verifyNever(() => source());
      },
    );
  }
  for (final entry
      in <(List<ProjectEntity>, List<String>, ResolveAssistantProjectsFailure)>[
        (
          [createProjectEntity(id: 'first')],
          ['first', 'unknown'],
          const AssistantProjectUnknownIdFailure(),
        ),
        (
          [createProjectEntity(id: 'first')],
          [' first '],
          const AssistantProjectUnknownIdFailure(),
        ),
        (
          [createProjectEntity(id: 'first')],
          ['First'],
          const AssistantProjectUnknownIdFailure(),
        ),
        (
          [createProjectEntity(id: 'first'), createProjectEntity(id: 'first')],
          ['first'],
          const AssistantProjectAmbiguousIdFailure(),
        ),
      ]) {
    test(
      'should reject the whole response when resolution fails with ${entry.$3.runtimeType} for ${entry.$2}',
      () async {
        source.stubCall(Right(entry.$1));
        final result = await parse(payload(ids: entry.$2));
        expect(result.left, isA<RemoteAssistantResponseResolutionFailure>());
        expect(result.left.cause, entry.$3);
        verify(() => source()).called(1);
      },
    );
  }

  test('should retain typed source failure when loading fails', () async {
    const failure = ProjectNetworkFailure();
    source.stubCall(const Left(failure));
    final result = await parse(payload(ids: ['first']));
    expect(result.left, isA<RemoteAssistantResponseResolutionFailure>());
    final cause = result.left.cause! as AssistantProjectsSourceFailure;
    expect(cause.cause, same(failure));
  });

  test(
    'should omit generated text from logging when parsing succeeds or fails',
    () async {
      const secret = 'private generated narrative';
      final logger = MockLogReporter();
      final interceptor = LogUseCaseInterceptor(logger);
      final oldStringify = EquatableConfig.stringify;
      EquatableConfig.stringify = true;
      addTearDown(() => EquatableConfig.stringify = oldStringify);
      for (final input in [payload(text: secret), '{"text":"$secret"']) {
        final params = ParseRemoteAssistantResponseParams(input);
        interceptor.onCall('parser', params);
        final result = await useCase(params);
        interceptor.onSuccess('parser', result);
        if (result.isLeft) {
          interceptor.onError('parser', result.left, null);
          expect(result.left.cause, isNull);
        }
      }
      final messages = verify(
        () => logger.debug(captureAny(), tag: 'parser'),
      ).captured;
      final errors = verify(
        () => logger.error(
          captureAny(),
          tag: 'parser',
          error: any<Object>(named: 'error'),
        ),
      ).captured;
      expect([...messages, ...errors].join(), isNot(contains(secret)));
      expect(messages.join(), contains('characters:'));
    },
  );
}
