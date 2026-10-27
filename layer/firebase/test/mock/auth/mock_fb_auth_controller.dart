import 'package:firebase/src/auth/fb_auth_controller.dart';
import 'package:mocktail/mocktail.dart';

class MockFbAuthController extends Mock implements FbAuthController {}

extension MockFbAuthControllerStub on MockFbAuthController {
  void stubIsSignedIn(bool isSignedIn) {
    when(() => this.isSignedIn).thenReturn(isSignedIn);
  }
}
