import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/portfolio/domain/entity/_entity.dart';
import 'package:portrai/src/feature/portfolio/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class WatchRefreshedPortfolioSectionsFailure extends BasicFailure {
  const WatchRefreshedPortfolioSectionsFailure({super.cause});
}

class WatchRefreshedPortfolioSectionsUnknownFailure
    extends WatchRefreshedPortfolioSectionsFailure {
  const WatchRefreshedPortfolioSectionsUnknownFailure({super.cause});
}

/// The sections each update refreshed, so screens showing them can reload.
@register
class WatchRefreshedPortfolioSectionsUseCase
    extends
        BaseNoParamStreamUseCase<
          Set<PortfolioSection>,
          WatchRefreshedPortfolioSectionsFailure
        > {
  WatchRefreshedPortfolioSectionsUseCase(this._portfolioUpdateRepository);

  final PortfolioUpdateRepository _portfolioUpdateRepository;

  @protected
  @override
  Stream<Set<PortfolioSection>> execute() =>
      _portfolioUpdateRepository.refreshedSections;

  @protected
  @override
  WatchRefreshedPortfolioSectionsFailure mapErrorToFailure(
    Object e,
    StackTrace st,
  ) {
    return WatchRefreshedPortfolioSectionsUnknownFailure(cause: e);
  }
}
