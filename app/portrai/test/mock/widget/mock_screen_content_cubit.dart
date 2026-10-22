import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

sealed class FakeScreenState {
  const FakeScreenState();
}

final class FakeLoadingState extends FakeScreenState {
  const FakeLoadingState();
}

final class FakeErrorState extends FakeScreenState {
  const FakeErrorState();
}

final class FakeLoadedState extends FakeScreenState {
  const FakeLoadedState();
}

class MockScreenContentCubit extends MockCubit<FakeScreenState>
    implements Cubit<FakeScreenState> {}

extension MockScreenContentCubitStub on MockScreenContentCubit {
  /// Starts at [initialState] and then emits each of [nextStates].
  void stubStates(
    FakeScreenState initialState, [
    List<FakeScreenState> nextStates = const [],
  ]) {
    when(() => state).thenReturn(initialState);
    whenListen(
      this,
      Stream<FakeScreenState>.fromIterable(nextStates),
      initialState: initialState,
    );
  }
}
