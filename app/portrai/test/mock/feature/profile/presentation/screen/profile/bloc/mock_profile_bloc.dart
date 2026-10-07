import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/bloc/_bloc.dart';

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

extension MockProfileBlocStub on MockProfileBloc {
  void stubState(ProfileState state) {
    when(() => this.state).thenReturn(state);
    whenListen(this, const Stream<ProfileState>.empty(), initialState: state);
  }
}
