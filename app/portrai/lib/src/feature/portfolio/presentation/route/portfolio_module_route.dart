import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/portfolio_screen.dart';
import 'package:portrai/src/route/route.dart';

class PortfolioModuleRoute extends ModuleRoute {
  PortfolioModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  static final PortfolioModuleRoute portfolio = PortfolioModuleRoute._(
    name: '/',
    path: '/',
    builder: (_, _, _) => const PortfolioScreen(),
  );
}
