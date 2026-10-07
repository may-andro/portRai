import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart';

class MockExperienceBloc extends MockBloc<ExperienceEvent, ExperienceState>
    implements ExperienceBloc {}

extension MockExperienceBlocStub on MockExperienceBloc {
  void stubState(ExperienceState state) {
    when(() => this.state).thenReturn(state);
    whenListen(
      this,
      const Stream<ExperienceState>.empty(),
      initialState: state,
    );
  }
}
