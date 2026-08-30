import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/bloc/_bloc.dart';

class MockFeatureFlagBloc extends MockBloc<FeatureFlagEvent, FeatureFlagState>
    implements FeatureFlagBloc {}

extension MockFeatureFlagBlocStub on MockFeatureFlagBloc {
  /// Stubs the bloc to expose [state] without emitting any further changes.
  void stubState(FeatureFlagState state) {
    when(() => this.state).thenReturn(state);
    whenListen(
      this,
      const Stream<FeatureFlagState>.empty(),
      initialState: state,
    );
  }
}
