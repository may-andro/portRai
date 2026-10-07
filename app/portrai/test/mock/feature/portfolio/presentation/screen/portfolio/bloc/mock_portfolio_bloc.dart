import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';

class MockPortfolioBloc extends MockBloc<PortfolioEvent, PortfolioState>
    implements PortfolioBloc {}

extension MockPortfolioBlocStub on MockPortfolioBloc {
  void stubState(PortfolioState state) {
    when(() => this.state).thenReturn(state);
    whenListen(this, const Stream<PortfolioState>.empty(), initialState: state);
  }
}
