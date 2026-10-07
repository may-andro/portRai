import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:meta/meta.dart';
import 'package:use_case/src/model/failure.dart';
import 'package:use_case/src/use_case/stream_use_case_mixin.dart';

abstract class BaseStreamUseCase<I, O, F extends Failure>
    with StreamUseCaseExecutionMixin<O, F> {
  Stream<Either<F, O>> call(I input) {
    return executeStreamWithInterceptors(
      tag: _tag,
      params: input,
      onExecute: () => execute(input),
    );
  }

  @protected
  Stream<O> execute(I input);

  String get _tag => '${runtimeType}_${DateTime.now().microsecondsSinceEpoch}';
}
