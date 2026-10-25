import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/presentation/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/portfolio/domain/use_case/mock_sync_portfolio_use_case.dart';

void main() {
  group('PortfolioUpdateListenerBloc', () {
    test('should sync the portfolio every time a check is requested', () async {
      final syncPortfolioUseCase = MockSyncPortfolioUseCase()
        ..stubCall(const Right({}));
      final bloc = PortfolioUpdateListenerBloc(syncPortfolioUseCase);
      addTearDown(bloc.close);

      bloc
        ..add(const PortfolioUpdateCheckRequestedEvent())
        ..add(const PortfolioUpdateCheckRequestedEvent());
      await pumpEventQueue();

      verify(() => syncPortfolioUseCase()).called(2);
      expect(bloc.state, const PortfolioUpdateListenerIdleState());
    });
  });
}
