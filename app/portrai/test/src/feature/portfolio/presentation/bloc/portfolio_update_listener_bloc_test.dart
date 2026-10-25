import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/presentation/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/portfolio/domain/use_case/mock_update_portfolio_use_case.dart';

void main() {
  group('PortfolioUpdateListenerBloc', () {
    test(
      'should update the portfolio every time a check is requested',
      () async {
        final updatePortfolioUseCase = MockUpdatePortfolioUseCase()
          ..stubCall(const Right({}));
        final bloc = PortfolioUpdateListenerBloc(updatePortfolioUseCase);
        addTearDown(bloc.close);

        bloc
          ..add(const PortfolioUpdateCheckRequestedEvent())
          ..add(const PortfolioUpdateCheckRequestedEvent());
        await pumpEventQueue();

        verify(() => updatePortfolioUseCase()).called(2);
        expect(bloc.state, const PortfolioUpdateListenerIdleState());
      },
    );
  });
}
