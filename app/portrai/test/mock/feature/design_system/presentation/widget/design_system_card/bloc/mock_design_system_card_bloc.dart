import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/presentation/widget/design_system_card/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class MockDesignSystemCardBloc
    extends MockBloc<DesignSystemCardEvent, DesignSystemCardState>
    implements DesignSystemCardBloc {}

extension MockDesignSystemCardBlocStub on MockDesignSystemCardBloc {
  void registerFactory() {
    appServiceLocator.registerFactory<DesignSystemCardBloc>(() => this);
  }

  void stubState() {
    when(() => state).thenReturn(const DesignSystemCardState());
    whenListen(
      this,
      const Stream<DesignSystemCardState>.empty(),
      initialState: const DesignSystemCardState(),
    );
  }
}
