import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/presentation/screen/sign_in/bloc/_bloc.dart';

class MockSignInBloc extends MockBloc<SignInEvent, SignInState>
    implements SignInBloc {}

extension MockSignInBlocStub on MockSignInBloc {
  void stubState(SignInState state) {
    when(() => this.state).thenReturn(state);
  }
}
