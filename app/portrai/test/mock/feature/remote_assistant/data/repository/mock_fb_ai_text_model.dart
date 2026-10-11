import 'package:firebase/firebase.dart';
import 'package:mocktail/mocktail.dart';

class MockFbAiTextModel extends Mock implements FbAiTextModel {}

class FakeFirebaseAiContents extends Fake implements Iterable<Content> {}
