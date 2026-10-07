import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/locale/domain/use_case/get_locale_stream_use_case.dart';
import 'package:portrai/src/feature/locale/presentation/widget/locale_listener_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../mock/feature/locale/domain/use_case/mock_get_locale_stream_use_case.dart';
import '../../../../../mock/feature/locale/test_data/locale_test_data.dart';
import '../../../../../util/test_wrapper_widget.dart';

void main() {
  group('LocaleListenerWidget', () {
    setUp(() async {
      await appServiceLocator.reset();
    });

    tearDown(() async {
      await appServiceLocator.reset();
    });

    testWidgets(
      'should rebuild with the latest locale when the locale stream emits a new value',
      (tester) async {
        final controller = StreamController<AppLocale>();
        addTearDown(controller.close);
        final getLocaleStreamUseCase = MockGetLocaleStreamUseCase()
          ..stubCall(controller.stream);
        appServiceLocator.registerSingleton<AppLocale>(
          () => createEnglishLocale(),
        );
        appServiceLocator.registerSingleton<GetLocaleStreamUseCase>(
          () => getLocaleStreamUseCase,
        );

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: LocaleListenerWidget(
              builder: (_, appLocale) => Text(appLocale.languageCode),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('en'), findsOneWidget);

        controller.add(createDutchLocale());
        await tester.pump();
        await tester.pump();

        expect(find.text('nl'), findsOneWidget);
      },
    );
  });
}
