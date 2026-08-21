import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/screen/_screen.dart';
import 'package:portrai/src/route/route.dart';

class ServiceModuleRoute extends ModuleRoute {
  ServiceModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  static final ServiceModuleRoute service = ServiceModuleRoute._(
    name: 'service',
    path: '/service/:${ServiceScreen.routePathParameter}',
    builder: (_, extra, params) {
      return ServiceScreen(service: extra as ServiceEntity);
    },
  );

  static final ServiceModuleRoute services = ServiceModuleRoute._(
    name: 'services',
    path: '/services',
    builder: (_, _, _) {
      return const ServicesScreen();
    },
  );
}
