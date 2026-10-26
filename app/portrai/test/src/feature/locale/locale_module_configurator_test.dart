import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:portrai/src/feature/locale/locale_module_configurator.dart';
import 'package:portrai/src/feature/locale/presentation/route/locale_module_route.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';
import 'package:use_case/use_case.dart';

import '../../../mock/feature/locale/domain/repository/mock_locale_repository.dart';
import '../../../mock/feature/locale/domain/use_case/mock_get_locale_use_case.dart';
import '../../../mock/feature/locale/test_data/locale_test_data.dart';
import '../../../mock/utility/mock_module_route_controller.dart';

void main() {
  group('LocaleModuleConfigurator', () {
    late MockLocaleRepository localeRepository;
    late MockModuleRouteController routeController;

    setUp(() async {
      await appServiceLocator.reset();
      final startLocale = createEnglishLocale();
      localeRepository = MockLocaleRepository()
        ..stubCurrentAppLocale(startLocale);
      routeController = MockModuleRouteController();
      when(
        () => routeController.register(LocaleModuleRoute.localeSelection),
      ).thenReturn(null);
      final getLocaleUseCase = MockGetLocaleUseCase()
        ..stubCall(Right(startLocale));

      appServiceLocator
        ..registerSingleton<AppLocale>(() => startLocale)
        ..registerSingleton<LocaleRepository>(() => localeRepository)
        ..registerFactory<GetLocaleUseCase>(() => getLocaleUseCase)
        ..registerSingleton<ModuleRouteController>(() => routeController);
    });

    tearDown(appServiceLocator.reset);

    test(
      'should resolve AppLocale to the repository locale when the language changes',
      () async {
        await LocaleModuleConfigurator().postDependenciesSetup(
          appServiceLocator,
        );
        expect(appServiceLocator.get<AppLocale>(), createEnglishLocale());

        localeRepository.stubCurrentAppLocale(createDutchLocale());

        expect(appServiceLocator.get<AppLocale>(), createDutchLocale());
      },
    );
  });
}
