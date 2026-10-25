import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/presentation/_presentation.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/portfolio/domain/use_case/mock_sync_portfolio_use_case.dart';

void main() {
  group('PortfolioUpdateListenerWidget', () {
    late MockSyncPortfolioUseCase syncPortfolioUseCase;

    setUp(() async {
      await appServiceLocator.reset();
      syncPortfolioUseCase = MockSyncPortfolioUseCase()
        ..stubCall(const Right({}));
      appServiceLocator.registerFactory<PortfolioUpdateListenerBloc>(
        () => PortfolioUpdateListenerBloc(syncPortfolioUseCase),
      );
    });

    tearDown(appServiceLocator.reset);

    testWidgets('should check for updates when the app starts and every '
        'time it comes back to the foreground', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: PortfolioUpdateListenerWidget(child: Text('Portfolio')),
        ),
      );
      await tester.pump();

      expect(find.text('Portfolio'), findsOneWidget);
      verify(() => syncPortfolioUseCase()).called(1);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      verify(() => syncPortfolioUseCase()).called(1);
    });
  });
}
