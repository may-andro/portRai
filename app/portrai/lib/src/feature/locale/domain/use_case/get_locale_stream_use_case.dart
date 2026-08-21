import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/locale/domain/repository/locale_repository.dart';

@register
class GetLocaleStreamUseCase {
  GetLocaleStreamUseCase(this._localeRepository);

  final LocaleRepository _localeRepository;

  Stream<AppLocale> call() => _localeRepository.appLocaleStream;
}
