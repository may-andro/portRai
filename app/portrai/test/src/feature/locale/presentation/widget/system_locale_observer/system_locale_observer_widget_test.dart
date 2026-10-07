import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:portrai/src/feature/locale/presentation/widget/system_locale_observer/system_locale_observer_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../mock/feature/locale/domain/use_case/mock_get_locale_use_case.dart';
import '../../../../../../mock/feature/locale/domain/use_case/mock_update_locale_use_case.dart';
import '../../../../../../mock/feature/locale/test_data/locale_test_data.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('SystemLocaleObserverWidget', () {
    setUp(() async {
      await appServiceLocator.reset();
    });

    tearDown(() async {
      await appServiceLocator.reset();
    });

    testWidgets(
      'should load the current locale and forward locale changes to the update use case',
      (tester) async {
        final getLocaleUseCase = MockGetLocaleUseCase()
          ..stubCall(Right<GetLocaleFailure, AppLocale>(createEnglishLocale()));
        final updateLocaleUseCase = MockUpdateLocaleUseCase()
          ..stubCall(
            locale: createDutchLocale(),
            result: const Right<UpdateLocaleFailure, void>(null),
          );
        appServiceLocator.registerSingleton<GetLocaleUseCase>(
          () => getLocaleUseCase,
        );
        appServiceLocator.registerSingleton<UpdateLocaleUseCase>(
          () => updateLocaleUseCase,
        );

        await tester.pumpWidget(
          const TestWidgetWrapper(
            child: SystemLocaleObserverWidget(child: SizedBox.shrink()),
          ),
        );
        await tester.pump();

        verify(() => getLocaleUseCase()).called(1);

        final state =
            tester.state(find.byType(SystemLocaleObserverWidget))
                as WidgetsBindingObserver;
        state.didChangeLocales(const [Locale('nl')]);
        await tester.pump();

        verify(() => updateLocaleUseCase(createDutchLocale())).called(1);
      },
    );
  });
}
