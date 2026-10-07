import 'package:flutter_test/flutter_test.dart';
import 'package:use_case/src/interceptor/use_case_interceptor.dart';
import 'package:use_case/src/interceptor/use_case_interceptor_controller.dart';
import 'package:use_case/src/model/failure.dart';
import 'package:use_case/src/use_case/base_no_param_stream_use_case.dart';
import 'package:use_case/src/use_case/base_stream_use_case.dart';

class RecordingInterceptor implements UseCaseInterceptor {
  int calls = 0;
  int successes = 0;
  int errors = 0;

  @override
  void onCall<Param>(String tag, Param param) => calls++;

  @override
  void onSuccess<Output>(String tag, Output result) => successes++;

  @override
  void onError(String tag, Object error, StackTrace? stackTrace) => errors++;
}

class FakeFailure extends Failure {}

class FakeNoParamStreamUseCase
    extends BaseNoParamStreamUseCase<int, FakeFailure> {
  FakeNoParamStreamUseCase(this.source, {this.throwOnExecute = false});

  final Stream<int> source;
  final bool throwOnExecute;

  @override
  Stream<int> execute() {
    if (throwOnExecute) throw Exception('Error');
    return source;
  }

  @override
  FakeFailure mapErrorToFailure(Object e, StackTrace st) => FakeFailure();
}

class FakeStreamUseCase extends BaseStreamUseCase<int, int, FakeFailure> {
  @override
  Stream<int> execute(int input) => Stream.value(input * 2);

  @override
  FakeFailure mapErrorToFailure(Object e, StackTrace st) => FakeFailure();
}

void main() {
  group('StreamUseCaseExecutionMixin', () {
    final interceptor = RecordingInterceptor();

    setUpAll(() => UseCaseInterceptorController().register(interceptor));

    setUp(() {
      interceptor
        ..calls = 0
        ..successes = 0
        ..errors = 0;
    });

    test('should wrap emitted values in Right when the stream emits', () async {
      final useCase = FakeNoParamStreamUseCase(Stream.fromIterable([1, 2]));

      final results = await useCase().toList();

      expect(results.map((e) => e.right), [1, 2]);
      expect(interceptor.calls, 1);
      expect(interceptor.successes, 2);
    });

    test('should map errors to Left without closing the stream', () async {
      final useCase = FakeNoParamStreamUseCase(
        Stream.fromFutures([
          Future<int>.value(1),
          Future<int>.error(Exception('boom')),
          Future<int>.value(3),
        ]),
      );

      final results = await useCase().toList();

      expect(results.map((e) => e.isRight), [true, false, true]);
      expect(interceptor.errors, 1);
    });

    test('should emit a Left when execute throws', () async {
      final useCase = FakeNoParamStreamUseCase(
        const Stream.empty(),
        throwOnExecute: true,
      );

      final results = await useCase().toList();

      expect(results.single.isLeft, isTrue);
    });

    test('should pass the input to execute when called with a param', () async {
      final results = await FakeStreamUseCase()(4).toList();

      expect(results.single.right, 8);
    });
  });
}
