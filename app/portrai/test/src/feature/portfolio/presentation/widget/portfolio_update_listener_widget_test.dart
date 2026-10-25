import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/presentation/_presentation.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/portfolio/domain/use_case/mock_update_portfolio_use_case.dart';

void main() {
  group('PortfolioUpdateListenerWidget', () {
    late MockUpdatePortfolioUseCase updatePortfolioUseCase;

    setUp(() async {
      await appServiceLocator.reset();
      updatePortfolioUseCase = MockUpdatePortfolioUseCase()
        ..stubCall(const Right({}));
      appServiceLocator.registerFactory<PortfolioUpdateListenerBloc>(
        () => PortfolioUpdateListenerBloc(updatePortfolioUseCase),
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
      verify(() => updatePortfolioUseCase()).called(1);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      verify(() => updatePortfolioUseCase()).called(1);
    });
  });
}
