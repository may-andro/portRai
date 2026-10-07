import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:meta/meta.dart';
import 'package:use_case/src/interceptor/use_case_interceptor_data_source.dart';
import 'package:use_case/src/model/failure.dart';

/// Stream counterpart of `UseCaseExecutionMixin`: every emitted value is
/// wrapped in a `Right`, and every error is mapped to a `Left` instead of
/// terminating the stream.
mixin StreamUseCaseExecutionMixin<O, F extends Failure> {
  final _interceptors = UseCaseInterceptorDataSource.registeredInterceptorList;

  Stream<Either<F, O>> executeStreamWithInterceptors({
    required String tag,
    required dynamic params,
    required Stream<O> Function() onExecute,
  }) {
    for (final interceptor in _interceptors) {
      interceptor.onCall(tag, params);
    }

    final Stream<O> source;
    try {
      source = onExecute();
    } catch (e, st) {
      return Stream.value(_doOnError(tag, e, st));
    }

    return source.transform(
      StreamTransformer<O, Either<F, O>>.fromHandlers(
        handleData: (data, sink) {
          final result = Right<F, O>(data);
          for (final interceptor in _interceptors) {
            interceptor.onSuccess(tag, result);
          }
          sink.add(result);
        },
        handleError: (Object e, StackTrace st, sink) {
          sink.add(_doOnError(tag, e, st));
        },
      ),
    );
  }

  @protected
  F mapErrorToFailure(Object e, StackTrace st);

  Left<F, O> _doOnError(String tag, Object e, StackTrace st) {
    final failure = mapErrorToFailure(e, st);
    for (final interceptor in _interceptors) {
      interceptor.onError(tag, e, st);
    }
    return Left(failure);
  }
}
