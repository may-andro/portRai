import 'package:tracking/src/model/action/action.dart';
import 'package:tracking/src/model/area/area.dart';
import 'package:tracking/src/model/tracking/tracking.dart';

class AppStartTracking extends Tracking {
  AppStartTracking()
    : super.settingCurrentArea(
        name: 'app_started',
        action: const SetupAction('uninitialised'),
        area: SplashArea(),
      );
}
