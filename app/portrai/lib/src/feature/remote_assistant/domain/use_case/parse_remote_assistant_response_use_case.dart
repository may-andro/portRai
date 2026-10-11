import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/domain/entity/_entity.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/ask_remote_portfolio_question_use_case.dart';
import 'package:use_case/use_case.dart';

class ParseRemoteAssistantResponseParams {
  const ParseRemoteAssistantResponseParams(this.payload);

  final String payload;

  @override
  String toString() =>
      'ParseRemoteAssistantResponseParams(characters: ${payload.length})';
}

sealed class ParseRemoteAssistantResponseFailure extends BasicFailure {
  const ParseRemoteAssistantResponseFailure({super.cause});
}

final class RemoteAssistantResponseInvalidFailure
    extends ParseRemoteAssistantResponseFailure {
  const RemoteAssistantResponseInvalidFailure();
}

final class RemoteAssistantResponseSizeFailure
    extends ParseRemoteAssistantResponseFailure {
  const RemoteAssistantResponseSizeFailure();
}

final class RemoteAssistantResponseVersionFailure
    extends ParseRemoteAssistantResponseFailure {
  const RemoteAssistantResponseVersionFailure();
}

final class RemoteAssistantResponseResolutionFailure
    extends ParseRemoteAssistantResponseFailure {
  const RemoteAssistantResponseResolutionFailure({
    required ResolveAssistantProjectsFailure cause,
  }) : super(cause: cause);
}

@register
class ParseRemoteAssistantResponseUseCase
    extends
        BaseUseCase<
          RemoteAssistantResponseEntity,
          ParseRemoteAssistantResponseParams,
          ParseRemoteAssistantResponseFailure
        > {
  ParseRemoteAssistantResponseUseCase(this._resolveAssistantProjectsUseCase);

  final ResolveAssistantProjectsUseCase _resolveAssistantProjectsUseCase;

  @protected
  @override
  Future<
    Either<ParseRemoteAssistantResponseFailure, RemoteAssistantResponseEntity>
  >
  execute(ParseRemoteAssistantResponseParams params) async {
    if (params.payload.length >
        RemoteAssistantRequestLimits.maxResponseCharacters) {
      return const Left(RemoteAssistantResponseSizeFailure());
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(params.payload);
    } on FormatException {
      // FormatException.source contains the untrusted generated payload.
      return const Left(RemoteAssistantResponseInvalidFailure());
    }
    if (decoded is! Map<String, dynamic> ||
        decoded.length != 3 ||
        !decoded.keys.toSet().containsAll(['version', 'text', 'projectIds'])) {
      return const Left(RemoteAssistantResponseInvalidFailure());
    }
    if (decoded['version'] is! int || decoded['version'] != 1) {
      return const Left(RemoteAssistantResponseVersionFailure());
    }
    final text = decoded['text'];
    final ids = decoded['projectIds'];
    if (text is! String ||
        text.trim().isEmpty ||
        ids is! List ||
        ids.any((id) => id is! String)) {
      return const Left(RemoteAssistantResponseInvalidFailure());
    }
    if (text.length > RemoteAssistantRequestLimits.maxResponseCharacters) {
      return const Left(RemoteAssistantResponseSizeFailure());
    }
    final resolved = await _resolveAssistantProjectsUseCase(ids.cast<String>());
    if (resolved.isLeft) {
      return Left(
        RemoteAssistantResponseResolutionFailure(cause: resolved.left),
      );
    }
    return Right(
      RemoteAssistantResponseEntity(text: text, projects: resolved.right),
    );
  }

  @protected
  @override
  ParseRemoteAssistantResponseFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => const RemoteAssistantResponseInvalidFailure();
}
