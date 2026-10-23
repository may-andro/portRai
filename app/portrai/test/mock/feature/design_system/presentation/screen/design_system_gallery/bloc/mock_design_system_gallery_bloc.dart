import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/presentation/screen/design_system_gallery/bloc/_bloc.dart';

class MockDesignSystemGalleryBloc
    extends MockBloc<DesignSystemGalleryEvent, DesignSystemGalleryState>
    implements DesignSystemGalleryBloc {}

extension MockDesignSystemGalleryBlocStub on MockDesignSystemGalleryBloc {
  void stubState(DesignSystemGalleryState state) {
    when(() => this.state).thenReturn(state);
    whenListen(
      this,
      Stream<DesignSystemGalleryState>.value(state),
      initialState: state,
    );
  }
}
