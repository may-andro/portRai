import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/bloc/_bloc.dart';

class MockExperiencesBloc extends MockBloc<ExperiencesEvent, ExperiencesState>
    implements ExperiencesBloc {}

extension MockExperiencesBlocStub on MockExperiencesBloc {
  void stubState(ExperiencesState state) {
    when(() => this.state).thenReturn(state);
    whenListen(
      this,
      const Stream<ExperiencesState>.empty(),
      initialState: state,
    );
  }
}
