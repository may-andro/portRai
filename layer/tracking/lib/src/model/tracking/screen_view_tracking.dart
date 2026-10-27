import 'package:tracking/src/model/tracking/tracking.dart';

class ScreenViewTracking extends Tracking {
  ScreenViewTracking({required super.area})
    : super.settingCurrentArea(name: 'screen_view', action: null);
}
