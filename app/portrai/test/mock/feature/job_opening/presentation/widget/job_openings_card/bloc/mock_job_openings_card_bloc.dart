import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/job_openings_card/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class MockJobOpeningsCardBloc
    extends MockBloc<JobOpeningsCardEvent, JobOpeningsCardState>
    implements JobOpeningsCardBloc {}

extension MockJobOpeningsCardBlocStub on MockJobOpeningsCardBloc {
  void registerFactory() {
    appServiceLocator.registerFactory<JobOpeningsCardBloc>(() => this);
  }

  void stubState() {
    when(() => state).thenReturn(const JobOpeningsCardState());
    whenListen(
      this,
      const Stream<JobOpeningsCardState>.empty(),
      initialState: const JobOpeningsCardState(),
    );
  }
}
