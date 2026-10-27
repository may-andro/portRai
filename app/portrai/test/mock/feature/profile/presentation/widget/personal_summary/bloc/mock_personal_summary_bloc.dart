import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/presentation/widget/personal_summary/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class MockPersonalSummaryBloc
    extends MockBloc<PersonalSummaryEvent, PersonalSummaryState>
    implements PersonalSummaryBloc {}

extension MockPersonalSummaryBlocStub on MockPersonalSummaryBloc {
  void registerFactory() {
    appServiceLocator.registerFactory<PersonalSummaryBloc>(() => this);
  }

  void stubState() {
    when(() => state).thenReturn(const PersonalSummaryState());
    whenListen(
      this,
      const Stream<PersonalSummaryState>.empty(),
      initialState: const PersonalSummaryState(),
    );
  }
}
