import 'package:core/core.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/locale/domain/repository/locale_repository.dart';
import 'package:use_case/use_case.dart';

sealed class WatchLocaleFailure extends BasicFailure {
  const WatchLocaleFailure({super.cause});
}

class WatchLocaleUnknownFailure extends WatchLocaleFailure {
  const WatchLocaleUnknownFailure({super.cause});
}

@register
class WatchLocaleUseCase
    extends BaseNoParamStreamUseCase<AppLocale, WatchLocaleFailure> {
  WatchLocaleUseCase(this._localeRepository);

  final LocaleRepository _localeRepository;

  @protected
  @override
  Stream<AppLocale> execute() => _localeRepository.appLocaleStream;

  @protected
  @override
  WatchLocaleFailure mapErrorToFailure(Object e, StackTrace st) {
    return WatchLocaleUnknownFailure(cause: e);
  }
}
